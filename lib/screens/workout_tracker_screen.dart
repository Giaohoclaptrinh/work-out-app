import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_app/models/exercise.dart';
import 'package:workout_app/services/exercise_service.dart';
import '../common/color_extension.dart';
import '../utils/firestore_helper.dart';
import '../widgets/round_button.dart';
import '../widgets/workout_row.dart';
import '../widgets/what_train_row.dart';
import '../widgets/round_textfield.dart';
import '../services/upload_exercises.dart';
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
  final TextEditingController _searchController = TextEditingController();

  List<Exercise> _allWorkouts = [];
  List<Exercise> _filteredWorkouts = [];
  List<Map<String, dynamic>> _tips = [];
  List<Exercise> _favorites = [];
  List<Exercise> _history = [];
  final List<Exercise> _custom = [];

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
        _exerciseService.getAllWorkouts(),
        _exerciseService.getWorkoutTips(),
        _exerciseService.getFavoriteWorkouts(),
        _exerciseService.getWorkoutHistory(),
      ]);

      if (mounted) {
        setState(() {
          _allWorkouts = futures[0] as List<Exercise>;
          _filteredWorkouts = _allWorkouts;
          _tips = futures[1] as List<Map<String, dynamic>>;
          _favorites = futures[2] as List<Exercise>;
          _history = futures[3] as List<Exercise>;
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
                leading: const Icon(Icons.link),
                title: const Text('Import from URL (local only)'),
                onTap: () async {
                  Navigator.pop(context);
                  final ex = await Navigator.of(context).push<Exercise>(
                    MaterialPageRoute(
                      builder: (_) => const UploadBrowserScreen(localOnly: true),
                    ),
                  );
                  if (ex != null) _addCustomWorkout(ex);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Import from Cloud'),
                onTap: () async {
                  Navigator.pop(context);
                  // Fetch from Firestore and copy locally to Custom list
                  final all = await _exerciseService.getAllWorkouts();
                  if (!mounted) return;
                  setState(() {
                    _custom
                      ..clear()
                      ..addAll(all);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterWorkouts();
  }

  // Add a locally imported custom workout (not persisted to Firestore)
  void _addCustomWorkout(Exercise ex) {
    setState(() {
      _custom.insert(0, ex);
    });
  }

  Future<void> _cleanupOldSampleData() async {
    try {
      // Lấy tất cả documents có source = 'Sample'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where('source', isEqualTo: 'Sample')
          .get();

      if (querySnapshot.docs.isEmpty) return;

      // Xóa theo batch
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  Future<void> _uploadSampleWorkouts() async {
    // Open import browser so user can choose which JSON to import
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UploadBrowserScreen()),
    );
    // After import, reload data
    if (mounted) await _loadData();
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
                  Icon(Icons.collections_bookmark, size: 64, color: TColor.gray),
                  const SizedBox(height: 8),
                  Text('No custom workouts yet', style: TextStyle(color: TColor.gray)),
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
                      'image': w.displayImage,
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
              textScaler: const TextScaler.linear(1.0), // fixed, not affected by global scaling
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: TColor.primaryColor1,
              unselectedLabelColor:
                  SettingsHelper.getSecondaryTextColor(context),
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
                const SizedBox(height: 10),

                // Category Filter
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 80,
                            maxWidth: 150,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TColor.primaryColor1
                                : SettingsHelper.getCardColor(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? TColor.primaryColor1
                                  : SettingsHelper.getSecondaryTextColor(
                                      context,
                                    ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : SettingsHelper.getTextColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
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
                    'image': workout.displayImage,
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
                        'image': workout.displayImage,
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
                        'image': workout.displayImage,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(
          exercise: workout,
          onFavoriteChanged: () {
            // Refresh data when favorite changes
            _loadData();
          },
        ),
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
