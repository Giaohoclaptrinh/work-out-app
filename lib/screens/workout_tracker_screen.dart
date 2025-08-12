import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // unused after switching to YouTube import
// import 'dart:convert'; // unused after switching to YouTube import

import 'package:workout_app/models/exercise.dart';
import 'package:workout_app/models/workout.dart' as workout_model;
import 'package:workout_app/services/exercise_service.dart';
import '../common/color_extension.dart';
import '../utils/firestore_helper.dart';

import '../widgets/workout_row.dart';
import '../widgets/what_train_row.dart';

import '../services/workout_service.dart';
import 'workout_detail_screen.dart';
import '../utils/settings_helper.dart';

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ExerciseService _exerciseService = ExerciseService();
  final WorkoutService _workoutService = WorkoutService();
  final TextEditingController _searchController = TextEditingController();

  List<Exercise> _allWorkouts = [];
  List<Exercise> _filteredWorkouts = [];
  List<Map<String, dynamic>> _tips = [];
  List<Exercise> _favorites = [];
  List<Exercise> _history = [];
  final List<Exercise> _custom = [];

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();

    // Reload data whenever tab changes back to this screen
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      // No-op here; actual reload handled on resume below
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh custom list when returning to this screen
    _exerciseService
        .getUserCustomWorkouts()
        .then((mine) {
          if (!mounted) return;
          setState(() {
            _custom
              ..clear()
              ..addAll(mine);
          });
        })
        .catchError((_) {
          // ignore errors silently
        });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _exerciseService.getAllWorkouts(),
        _exerciseService.getWorkoutTips(),
        _exerciseService.getFavoriteWorkouts(),
        _exerciseService.getWorkoutHistory(),
        _exerciseService.getUserCustomWorkouts(),
      ]);

      if (mounted) {
        setState(() {
          _allWorkouts = futures[0] as List<Exercise>;
          _filteredWorkouts = _allWorkouts;
          _tips = futures[1] as List<Map<String, dynamic>>;
          _favorites = futures[2] as List<Exercise>;
          _history = futures[3] as List<Exercise>;
          _custom
            ..clear()
            ..addAll(futures[4] as List<Exercise>);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterWorkouts() {
    setState(() {
      _filteredWorkouts = _allWorkouts.where((workout) {
        return workout.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            workout.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterWorkouts();
  }

  Future<void> _showImportMenu() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload Workout Data from JSON'),
                onTap: () async {
                  Navigator.pop(context);
                  _uploadWorkoutData();
                },
              ),

              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create Custom Workout'),
                onTap: () async {
                  Navigator.pop(context);
                  _showCreateWorkoutDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle),
                title: const Text('Import from YouTube'),
                onTap: () async {
                  Navigator.pop(context);
                  _showYouTubeInputDialog();
                },
              ),

              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Import from Cloud'),
                onTap: () async {
                  Navigator.pop(context);
                  // Fetch user's custom workouts from Firestore
                  final mine = await _exerciseService.getUserCustomWorkouts();
                  if (!mounted) return;
                  setState(() {
                    _custom
                      ..clear()
                      ..addAll(mine);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: const Text('Import Workouts from Firebase'),
                onTap: () async {
                  Navigator.pop(context);
                  _importWorkoutsFromFirebase();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadWorkoutData() async {
    try {
      await _workoutService.uploadWorkoutDataFromJson();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout data uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload data
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading workout data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importWorkoutsFromFirebase() async {
    try {
      final workouts = await _workoutService.importWorkoutsFromFirestore();
      if (mounted) {
        setState(() {
          _custom.clear();
          // Convert Workout to Exercise for compatibility
          for (final workout in workouts) {
            final exercise = Exercise(
              id: workout.id,
              name: workout.name,
              description: workout.description,
              category: workout.category,
              imageUrl: workout.image,
              muscleGroups: workout.muscleGroups,
              instructions:
                  workout.description, // Use description as instructions
              difficulty: workout.difficulty ?? 'Intermediate',
              equipment: workout.equipment,
              duration: workout.duration,
              calories: workout.calories,
              steps: workout.steps.cast<WorkoutStep>(),
              isFavorite: workout.isFavorite,
              type: 'workout',
              workout: workout.toJson(),
            );
            _custom.add(exercise);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${workouts.length} workouts from Firebase!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing workouts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateWorkoutDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController youtubeUrlController = TextEditingController();
    String selectedDifficulty = 'Intermediate';
    String selectedCategory = 'Custom';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Workout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // YouTube URL (optional)
              TextField(
                controller: youtubeUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL (optional)',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Beginner', 'Intermediate', 'Advanced']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (value) {
                        selectedDifficulty = value!;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'Custom',
                                'Cardio',
                                'Strength',
                                'Flexibility',
                                'Yoga',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (value) {
                        selectedCategory = value!;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final duration = int.tryParse(durationController.text) ?? 10;
              final calories = int.tryParse(caloriesController.text) ?? 100;
              final youtubeUrl = youtubeUrlController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a workout name'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Parse YouTube URL if provided
              String? videoId;
              String? embeddedUrl;
              String? thumbnailUrl;
              if (youtubeUrl.isNotEmpty &&
                  (youtubeUrl.contains('youtube.com') ||
                      youtubeUrl.contains('youtu.be'))) {
                try {
                  if (youtubeUrl.contains('youtube.com/watch?v=')) {
                    videoId = youtubeUrl.split('watch?v=')[1].split('&')[0];
                  } else if (youtubeUrl.contains('youtu.be/')) {
                    videoId = youtubeUrl.split('youtu.be/')[1].split('?')[0];
                  }
                  if (videoId != null && videoId.isNotEmpty) {
                    embeddedUrl = 'https://www.youtube.com/embed/$videoId';
                    thumbnailUrl =
                        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
                  }
                } catch (_) {}
              }

              final exercise = Exercise(
                id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                description: description,
                category: selectedCategory,
                imageUrl: thumbnailUrl, // Use YouTube thumbnail if provided
                muscleGroups: [selectedCategory],
                instructions: description,
                difficulty: selectedDifficulty,
                equipment: 'Bodyweight',
                duration: duration,
                calories: calories,
                steps: null,
                isFavorite: false,
                type: 'custom',
                workout: {
                  'name': name,
                  'description': description,
                  'category': selectedCategory,
                  'difficulty': selectedDifficulty,
                  'duration': duration,
                  'calories': calories,
                  'videoUrl': embeddedUrl,
                  'youtubeId': videoId,
                  'thumbnailUrl': thumbnailUrl,
                },
              );

              setState(() {
                _custom.add(exercise);
              });

              // Persist to Firestore under user's customWorkouts
              ExerciseService().saveCustomWorkout(exercise).catchError((e) {
                // Non-blocking: just log error
                // ignore: avoid_print
                print('Failed to save custom workout: $e');
                return '';
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Created custom workout: $name'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showYouTubeInputDialog() {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    String selectedDifficulty = 'Intermediate';
    String selectedCategory = 'Custom';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Workout from YouTube'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter a YouTube video URL to create a workout:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                  helperText: 'Paste YouTube video URL here',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Workout Title',
                  border: OutlineInputBorder(),
                  helperText: 'Enter a title for this workout',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  helperText: 'Brief description of the workout',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Beginner', 'Intermediate', 'Advanced']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (value) {
                        selectedDifficulty = value!;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'Custom',
                                'Cardio',
                                'Strength',
                                'Flexibility',
                                'Yoga',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (value) {
                        selectedCategory = value!;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = urlController.text.trim();
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final duration = int.tryParse(durationController.text) ?? 10;
              final calories = int.tryParse(caloriesController.text) ?? 100;

              if (url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a YouTube URL'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a workout title'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _importWorkoutFromYouTube(
                url,
                title,
                description,
                duration,
                calories,
                selectedDifficulty,
                selectedCategory,
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importWorkoutFromYouTube(
    String url,
    String title,
    String description,
    int duration,
    int calories,
    String difficulty,
    String category,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating workout from YouTube...'),
            ],
          ),
        ),
      );

      // Validate YouTube URL
      if (!url.contains('youtube.com') && !url.contains('youtu.be')) {
        throw Exception('Please enter a valid YouTube URL');
      }

      // Extract video ID from YouTube URL
      String videoId = '';
      if (url.contains('youtube.com/watch?v=')) {
        videoId = url.split('watch?v=')[1].split('&')[0];
      } else if (url.contains('youtu.be/')) {
        videoId = url.split('youtu.be/')[1].split('?')[0];
      } else {
        throw Exception('Invalid YouTube URL format');
      }

      // Create YouTube thumbnail URL
      final thumbnailUrl =
          'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

      // Create embedded video URL for WebView
      final embeddedUrl = 'https://www.youtube.com/embed/$videoId';

      // Create Exercise object from YouTube video
      final exercise = Exercise(
        id: 'youtube_${DateTime.now().millisecondsSinceEpoch}',
        name: title,
        description: description,
        category: category,
        imageUrl: thumbnailUrl,
        muscleGroups: [category],
        instructions: description,
        difficulty: difficulty,
        equipment: 'Bodyweight',
        duration: duration,
        calories: calories,
        steps: null,
        isFavorite: false,
        type: 'youtube',
        workout: {
          'name': title,
          'description': description,
          'category': category,
          'difficulty': difficulty,
          'duration': duration,
          'calories': calories,
          'videoUrl': embeddedUrl,
          'youtubeId': videoId,
          'thumbnailUrl': thumbnailUrl,
        },
      );

      setState(() {
        _custom.add(exercise);
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully created workout from YouTube: $title'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating workout from YouTube: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildCustomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const SizedBox(height: 16),
          if (_custom.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.collections_bookmark,
                    size: 64,
                    color: TColor.gray,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No custom workouts yet',
                    style: TextStyle(color: TColor.gray),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _custom.map((w) {
                return Dismissible(
                  key: ValueKey('custom-' + w.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() => _custom.remove(w));
                  },
                  child: WorkoutRow(
                    wObj: {
                      'name': w.name,
                      'image': w.imageUrl ?? '',
                      'kcal': (w.calories ?? 0).toString(),
                      'time': (w.duration ?? 0).toString(),
                      'progress': 0.0,
                      'id': w.id,
                    },
                    onPressed: () => _navigateToWorkoutDetail(w),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    try {
      await FirestoreHelper.clearWorkoutHistory();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout history cleared!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAllTips() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Workout Tips',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tips.length,
                itemBuilder: (context, index) {
                  final tip = _tips[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: WhatTrainRow(wObj: tip),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: SettingsHelper.getCardColor(context),
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Workout Tracker",
          style: SettingsHelper.getTitleStyle(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upload, color: TColor.primaryColor1),
            onPressed: _showImportMenu,
            tooltip: 'Import',
          ),
          IconButton(
            icon: Icon(Icons.clear, color: TColor.primaryColor1),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(
                1.0,
              ), // fixed, not affected by global scaling
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: TColor.primaryColor1,
              unselectedLabelColor: SettingsHelper.getSecondaryTextColor(
                context,
              ),
              indicatorColor: TColor.primaryColor1,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: const [
                Tab(text: "Workouts"),
                Tab(text: "Favorites"),
                Tab(text: "History"),
                Tab(text: "Custom"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: SettingsHelper.getCardColor(context),
                    borderRadius: BorderRadius.circular(22.5),
                    border: Border.all(
                      color: SettingsHelper.getSecondaryTextColor(context),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: SettingsHelper.getTextStyle(context),
                    decoration: InputDecoration(
                      hintText: "Search workouts...",
                      hintStyle: SettingsHelper.getSubtitleStyle(context),
                      prefixIcon: Icon(
                        Icons.search,
                        color: SettingsHelper.getSecondaryTextColor(context),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWorkoutsTab(),
                _buildFavoritesTab(),
                _buildHistoryTab(),
                _buildCustomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tips Section
            if (_tips.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Workout Tips",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showAllTips();
                    },
                    child: Text(
                      "See More",
                      style: TextStyle(color: TColor.gray, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._tips
                  .take(3)
                  .map(
                    (tip) => WhatTrainRow(wObj: tip),
                  ), // Show only first 3 tips
              const SizedBox(height: 20),
            ],

            // Workouts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Workouts",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "${_filteredWorkouts.length} workouts",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_filteredWorkouts.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: TColor.gray),
                    const SizedBox(height: 16),
                    Text(
                      "No workouts found",
                      style: TextStyle(color: TColor.gray, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try adjusting your search or category filter",
                      style: TextStyle(color: TColor.gray, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ..._filteredWorkouts.map(
                (workout) => WorkoutRow(
                  wObj: {
                    'name': workout.name,
                    'image': workout.imageUrl ?? '',
                    'kcal': workout.calories.toString(),
                    'time': workout.duration.toString(),
                    'progress': 0.0,
                    'id': workout.id,
                  },
                  onPressed: () => _navigateToWorkoutDetail(workout),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: TColor.gray),
                  const SizedBox(height: 16),
                  Text(
                    "No favorite workouts yet",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add workouts to your favorites to see them here",
                    style: TextStyle(color: TColor.gray, fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Favorites",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "${_favorites.length} favorites",
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._favorites.map(
                    (workout) => WorkoutRow(
                      wObj: {
                        'name': workout.name,
                        'image': workout.imageUrl ?? '',
                        'kcal': workout.calories.toString(),
                        'time': workout.duration.toString(),
                        'progress': 0.0,
                        'id': workout.id,
                      },
                      onPressed: () => _navigateToWorkoutDetail(workout),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: TColor.gray),
                  const SizedBox(height: 16),
                  Text(
                    "No workout history yet",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Complete workouts to see your history here",
                    style: TextStyle(color: TColor.gray, fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Workout History",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "${_history.length} completed",
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._history.map(
                    (workout) => WorkoutRow(
                      wObj: {
                        'name': workout.name,
                        'image': workout.imageUrl ?? '',
                        'kcal': workout.calories.toString(),
                        'time': workout.duration.toString(),
                        'progress': 1.0, // Completed
                        'id': workout.id,
                      },
                      onPressed: () => _navigateToWorkoutDetail(workout),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateToWorkoutDetail(Exercise workout) {
    // Convert Exercise to Workout for the detail screen
    final workoutData = workout_model.Workout(
      id: workout.id,
      name: workout.name,
      description: workout.description,
      image: workout.imageUrl ?? '',
      category: workout.category,
      duration: workout.duration ?? 0,
      calories: workout.calories ?? 0,
      difficulty: workout.difficulty,
      muscleGroups: workout.muscleGroups,
      steps: workout.steps?.cast<workout_model.WorkoutStep>() ?? [],
      isFavorite: workout.isFavorite,
      completedAt: null,
      videoUrl: workout.workout?['videoUrl'], // Get videoUrl from workout data
      equipment: workout.equipment,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workout: workoutData),
      ),
    ).then((result) {
      // Refresh data when returning from detail screen
      if (result == true) {
        _loadData();
      }
    });
  }
}
