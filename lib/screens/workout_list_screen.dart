import 'package:flutter/material.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No workouts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first workout to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      /*
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 0, // No sample data
        itemBuilder: (context, index) {
          // This will not be called since itemCount is 0
          return const SizedBox.shrink();
        },
      ),
      */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateWorkoutDialog(context);
        },
        child: const Icon(Icons.add),
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
}
