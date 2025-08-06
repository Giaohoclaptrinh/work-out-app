import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: SampleWorkouts.workouts.length,
        itemBuilder: (context, index) {
          final workout = SampleWorkouts.workouts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                workout.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (workout.description != null) ...[
                    const SizedBox(height: 4),
                    Text(workout.description!),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${workout.exercises.length} exercises',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              trailing: workout.completed
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(
                      Icons.play_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onTap: () {
                _showWorkoutDetails(context, workout);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateWorkoutDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, Workout workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Workout title
              Text(
                workout.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (workout.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  workout.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 16),

              // Exercises list
              Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: workout.exercises.length,
                  itemBuilder: (context, index) {
                    final workoutExercise = workout.exercises[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workoutExercise.exercise.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workoutExercise.exercise.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sets: ${workoutExercise.sets.length}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            ...workoutExercise.sets.asMap().entries.map((
                              entry,
                            ) {
                              final setIndex = entry.key + 1;
                              final set = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  top: 4,
                                ),
                                child: Text(
                                  'Set $setIndex: ${set.reps} reps${set.duration != null ? ' (${set.duration}s)' : ''}${set.weight != null ? ' @ ${set.weight}kg' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Start workout button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startWorkout(context, workout);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Workout'),
        content: const Text('Workout creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startWorkout(BuildContext context, Workout workout) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting workout: ${workout.name}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to workout session screen
          },
        ),
      ),
    );
  }
}
