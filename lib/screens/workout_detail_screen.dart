import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../widgets/round_button.dart';
import '../widgets/step_detail_row.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final WorkoutService _workoutService = WorkoutService();
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _workoutService.isFavorite(widget.workout.id);
      setState(() {
        _isFavorite = isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _workoutService.removeFromFavorites(widget.workout.id);
      } else {
        await _workoutService.addToFavorites(widget.workout.id);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Added to favorites!' : 'Removed from favorites!',
            ),
            backgroundColor: _isFavorite ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeWorkout() async {
    try {
      await _workoutService.completeWorkout(widget.workout.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout completed! Great job!'),
            backgroundColor: Colors.green,
          ),
        );
        // Return true to indicate workout was completed
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error completing workout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error completing workout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: TColor.primaryColor1,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.workout.image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.workout.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.timer, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.workout.duration} min',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.workout.calories} cal',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _isLoading ? null : _toggleFavorite,
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.workout.description,
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Workout Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Difficulty',
                          widget.workout.difficulty,
                          Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          'Category',
                          widget.workout.category,
                          Icons.category,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Muscle Groups
                  if (widget.workout.muscleGroups.isNotEmpty) ...[
                    Text(
                      'Muscle Groups',
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.workout.muscleGroups.map((muscle) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: TColor.primaryColor1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            muscle,
                            style: TextStyle(
                              color: TColor.primaryColor1,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Workout Steps
                  Text(
                    'Workout Steps',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (widget.workout.steps.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: TColor.gray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No steps available',
                            style: TextStyle(color: TColor.gray, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  else
                    ...widget.workout.steps.map(
                      (step) => StepDetailRow(
                        sObj: {
                          'no': step.stepNumber.toString(),
                          'title': step.title,
                          'detail': step.description,
                          'image': step.image,
                          'duration': step.duration.toString(),
                          'reps': step.reps?.toString(),
                          'sets': step.sets?.toString(),
                        },
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: RoundButton(
                          title: 'Start Workout',
                          type: RoundButtonType.bgGradient,
                          onPressed: _completeWorkout,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: TColor.primaryColor1, size: 24),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: TColor.gray, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: TColor.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
