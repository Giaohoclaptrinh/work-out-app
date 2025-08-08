import 'package:flutter/material.dart';
import 'package:workout_app/models/exercise.dart';
import 'package:workout_app/services/exercise_service.dart';
import '../common/color_extension.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/gym_visual_service.dart';
import '../utils/firestore_helper.dart';
import '../widgets/round_button.dart';
import '../widgets/workout_row.dart';
import '../widgets/what_train_row.dart';
import '../widgets/round_textfield.dart';
import 'workout_detail_screen.dart';

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final WorkoutService _workoutService = WorkoutService();
  final GymVisualService _gymVisualService = GymVisualService();
  final ExerciseService _exerciseService = ExerciseService();
  final TextEditingController _searchController = TextEditingController();

  List<Workout> _allWorkouts = [];
  List<Workout> _filteredWorkouts = [];
  List<Map<String, dynamic>> _tips = [];
  List<Workout> _favorites = [];
  List<Workout> _history = [];
  List<Exercise> _exercises = [];

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Cardio',
    'Strength',
    'Flexibility',
    'Yoga',
    'HIIT',
    'Pilates',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _exerciseService.getAllExercises();
      if (mounted) {
        setState(() {
          _exercises = exercises;
        });
      }
    } catch (e) {
      print('Error loading exercises: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _workoutService.getAllWorkouts(),
        _workoutService.getWorkoutTips(),
        _workoutService.getFavoriteWorkouts(),
        _workoutService.getWorkoutHistory(),
      ]);

      if (mounted) {
        setState(() {
          _allWorkouts = futures[0] as List<Workout>;
          _filteredWorkouts = _allWorkouts;
          _tips = futures[1] as List<Map<String, dynamic>>;
          _favorites = futures[2] as List<Workout>;
          _history = futures[3] as List<Workout>;
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
        final matchesSearch =
            workout.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            workout.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
        final matchesCategory =
            _selectedCategory == 'All' || workout.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterWorkouts();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterWorkouts();
  }

  Future<void> _importGymVisualData() async {
    try {
      await _gymVisualService.importGymVisualExercises();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GymVisual data imported successfully!'),
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
            content: Text('Error importing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> _importAllGymVisualWorkouts() async {
    try {
      await FirestoreHelper.addAllGymVisualWorkoutsToFirestore();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All GymVisual workouts imported successfully!'),
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
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Workout Tracker",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: TColor.primaryColor1),
            onPressed: _importGymVisualData,
            tooltip: 'Import GymVisual Data',
          ),
          IconButton(
            icon: Icon(Icons.fitness_center, color: TColor.primaryColor1),
            onPressed: _importAllGymVisualWorkouts,
            tooltip: 'Import All GymVisual Workouts',
          ),
          IconButton(
            icon: Icon(Icons.clear, color: TColor.primaryColor1),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: TColor.primaryColor1,
          unselectedLabelColor: TColor.gray,
          indicatorColor: TColor.primaryColor1,
          tabs: const [
            Tab(text: "Workouts"),
            Tab(text: "Favorites"),
            Tab(text: "History"),
            
          ],
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
                SizedBox(
                  height: 45,
                  child: RoundTextField(
                    controller: _searchController,
                    hintText: "Search workouts...",
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter
                SizedBox(
                  height: 5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: RoundButton(
                          title: category,
                          type: isSelected
                              ? RoundButtonType.bgGradient
                              : RoundButtonType.textGradient,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          onPressed: () => _onCategoryChanged(category),
                        ),
                      );
                    },
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
                _buildExercisesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadExercises,
      child: _exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: TColor.gray),
                  const SizedBox(height: 16),
                  Text(
                    "No exercises found",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try importing or syncing exercises",
                    style: TextStyle(color: TColor.gray, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.category),
                  onTap: () {
                    // TODO: Navigate to exercise detail or video
                  },
                );
              },
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
                (workout) => GestureDetector(
                  onTap: () => _navigateToWorkoutDetail(workout),
                  child: WorkoutRow(
                    wObj: {
                      'name': workout.name,
                      'image': workout.image,
                      'kcal': workout.calories.toString(),
                      'time': workout.duration.toString(),
                      'progress': 0.0,
                    },
                  ),
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
                    (workout) => GestureDetector(
                      onTap: () => _navigateToWorkoutDetail(workout),
                      child: WorkoutRow(
                        wObj: {
                          'name': workout.name,
                          'image': workout.image,
                          'kcal': workout.calories.toString(),
                          'time': workout.duration.toString(),
                          'progress': 0.0,
                        },
                      ),
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
                    (workout) => GestureDetector(
                      onTap: () => _navigateToWorkoutDetail(workout),
                      child: WorkoutRow(
                        wObj: {
                          'name': workout.name,
                          'image': workout.image,
                          'kcal': workout.calories.toString(),
                          'time': workout.duration.toString(),
                          'progress': 1.0, // Completed
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateToWorkoutDetail(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workout: workout),
      ),
    ).then((result) {
      // Refresh data when returning from detail screen
      // If workout was completed (result == true), refresh immediately
      if (result == true) {
        _loadData();
      }
    });
  }
}
