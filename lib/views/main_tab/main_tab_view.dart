import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../../common/color_extension.dart';
import '../home/home_view.dart';
import '../../screens/workout_tracker_screen.dart';
import '../../screens/meal_planner_screen.dart';
import '../profile/profile_view.dart';
import '../../services/exercise_service.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart' as workout_model;
import '../../screens/workout_detail_screen.dart';
import '../../widgets/top_notification_banner.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectedTabIndex = 0;
  late PageController controller;

  final List<IconData> iconList = [
    Icons.home,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: selectedTabIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });
    controller.jumpToPage(index);
  }

  void _showGlobalSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GlobalSearchDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      floatingActionButton: InkWell(
        onTap: () {
          _showGlobalSearchDialog(context);
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.secondaryG),
            borderRadius: BorderRadius.circular(27.5),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(Icons.search, color: TColor.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: selectedTabIndex,
        gapLocation: GapLocation.center,
        activeColor: TColor.primaryColor1,
        inactiveColor: TColor.gray,
        splashSpeedInMilliseconds: 300,
        onTap: onTabSelected,
        backgroundColor: Colors.white,
        height: 70,
      ),
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        children: [
          const HomeView(),
          const WorkoutTrackerScreen(),
          const MealPlannerScreen(),
          const ProfileTabView(),
        ],
      ),
    );
  }
}

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(),
        title: Text(
          "Profile",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Future: Show more options
            },
            icon: Icon(Icons.more_horiz, color: TColor.black),
          ),
        ],
      ),
      body: ProfileView(),
    );
  }
}

class GlobalSearchDialog extends StatefulWidget {
  const GlobalSearchDialog({super.key});

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ExerciseService _exerciseService = ExerciseService();

  List<Exercise> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      // Fetch workouts, user's custom workouts, and exercises in parallel
      final fetched = await Future.wait<List<Exercise>>([
        _exerciseService.getAllWorkouts(),
        _exerciseService.getUserCustomWorkouts(),
        // drop exercises for perf if not needed frequently; re-enable if required
        // _exerciseService.getAllExercises(),
      ]);

      // Merge and de-duplicate by id
      final Map<String, Exercise> idToExercise = {};
      for (final list in fetched) {
        for (final e in list) {
          idToExercise[e.id] = e;
        }
      }

      final merged = idToExercise.values.toList(growable: false);

      final results = merged.where((exercise) {
        final nameMatch = exercise.name.toLowerCase().contains(
          query.toLowerCase(),
        );
        final descriptionMatch = exercise.description.toLowerCase().contains(
          query.toLowerCase(),
        );
        final categoryMatch = exercise.category.toLowerCase().contains(
          query.toLowerCase(),
        );
        final muscleGroupMatch = exercise.muscleGroups.any(
          (muscle) => muscle.toLowerCase().contains(query.toLowerCase()),
        );

        return nameMatch ||
            descriptionMatch ||
            categoryMatch ||
            muscleGroupMatch;
      }).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });

        if (mounted) {
          showTopBanner(
            context,
            title: 'Search',
            message: 'Search failed: $e',
            backgroundColor: Colors.red,
            icon: Icons.error_outline,
          );
        }
    }
  }

  void _navigateToWorkoutDetail(Exercise exercise) {
    Navigator.pop(context); // Close search dialog

    // Convert Exercise to Workout for the detail screen
    final workoutData = workout_model.Workout(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      image: exercise.imageUrl ?? '',
      category: exercise.category,
      duration: exercise.duration ?? 0,
      calories: exercise.calories ?? 0,
      difficulty: exercise.difficulty,
      muscleGroups: exercise.muscleGroups,
      steps: exercise.steps?.cast<workout_model.WorkoutStep>() ?? [],
      isFavorite: exercise.isFavorite,
      completedAt: null,
      videoUrl: exercise.workout?['videoUrl'],
      equipment: exercise.equipment,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workout: workoutData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header with search bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: TColor.primaryColor1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            'Search workouts, exercises, muscle groups...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: TColor.gray),
                      ),
                      onChanged: _performSearch,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: TColor.gray),
                  ),
                ],
              ),
            ),

            // Search results
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: TColor.primaryColor1,
                      ),
                    )
                  : _searchQuery.isEmpty
                  ? _buildSearchSuggestions()
                  : _searchResults.isEmpty
                  ? _buildNoResults()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      {
        'title': 'Popular Searches',
        'items': ['Push-up', 'Plank', 'Squats', 'Lunges'],
      },
      {
        'title': 'Muscle Groups',
        'items': ['Chest', 'Back', 'Legs', 'Core'],
      },
      {
        'title': 'Categories',
        'items': ['Strength', 'Cardio', 'Flexibility'],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final section = suggestions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section['title'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TColor.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (section['items'] as List<String>).map((item) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = item;
                    _performSearch(item);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: TColor.primaryColor1.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(color: TColor.primaryColor1),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: TColor.gray),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_searchQuery"',
            style: TextStyle(color: TColor.gray, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or browse categories',
            style: TextStyle(color: TColor.gray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final exercise = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(colors: TColor.primaryG),
              ),
              child: (exercise.imageUrl ?? '').startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        exercise.imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          exercise.isWorkout
                              ? Icons.fitness_center
                              : Icons.sports_gymnastics,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      exercise.isWorkout
                          ? Icons.fitness_center
                          : Icons.sports_gymnastics,
                      color: Colors.white,
                    ),
            ),
            title: Text(
              exercise.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TColor.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.category,
                  style: TextStyle(color: TColor.primaryColor1, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.muscleGroups.join(', '),
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (exercise.duration != null || exercise.calories != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        if (exercise.duration != null) ...[
                          Icon(Icons.schedule, size: 12, color: TColor.gray),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${exercise.duration} min',
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                        if (exercise.duration != null &&
                            exercise.calories != null)
                          const SizedBox(width: 12),
                        if (exercise.calories != null) ...[
                          Icon(
                            Icons.local_fire_department,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${exercise.calories} cal',
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: TColor.gray,
              size: 16,
            ),
            onTap: () => _navigateToWorkoutDetail(exercise),
          ),
        );
      },
    );
  }
}
