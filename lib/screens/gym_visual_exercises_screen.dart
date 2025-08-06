import 'package:flutter/material.dart';
import '../services/gym_visual_service.dart';
import '../models/exercise.dart';
import '../common/color_extension.dart';

class GymVisualExercisesScreen extends StatefulWidget {
  const GymVisualExercisesScreen({super.key});

  @override
  State<GymVisualExercisesScreen> createState() => _GymVisualExercisesScreenState();
}

class _GymVisualExercisesScreenState extends State<GymVisualExercisesScreen> {
  final GymVisualService _gymVisualService = GymVisualService();
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = false;
  String _selectedDifficulty = 'All';
  String _selectedEquipment = 'All';
  String _searchQuery = '';

  final List<String> _difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  final List<String> _equipment = ['All', 'None', 'Weight', 'Hyperextension Bench', 'Incline Bench, Weight'];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await _gymVisualService.getGymVisualExercises();
      setState(() {
        _exercises = exercises;
        _filteredExercises = exercises;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load exercises: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importGymVisualExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _gymVisualService.importGymVisualExercises();
      await _loadExercises();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully imported GymVisual exercises!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import exercises: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = _exercises.where((exercise) {
        // Filter by search query
        final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            exercise.description.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filter by difficulty
        final matchesDifficulty = _selectedDifficulty == 'All' ||
            exercise.id == '2043' && _selectedDifficulty == 'Beginner' ||
            exercise.id == '1024' && _selectedDifficulty == 'Beginner' ||
            exercise.id == '186012' && _selectedDifficulty == 'Intermediate' ||
            exercise.id == '1251' && _selectedDifficulty == 'Intermediate' ||
            exercise.id == '1250' && _selectedDifficulty == 'Advanced';

        // Filter by equipment (simplified for demo)
        final matchesEquipment = _selectedEquipment == 'All' ||
            exercise.id == '2043' && _selectedEquipment == 'None' ||
            exercise.id == '1024' && _selectedEquipment == 'None' ||
            exercise.id == '186012' && _selectedEquipment == 'Hyperextension Bench' ||
            exercise.id == '1251' && _selectedEquipment == 'Weight' ||
            exercise.id == '1250' && _selectedEquipment == 'Incline Bench, Weight';

        return matchesSearch && matchesDifficulty && matchesEquipment;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymVisual Exercises'),
        backgroundColor: TColor.primaryColor1,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterExercises();
                  },
                ),
                const SizedBox(height: 16),
                
                // Filter Options
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDifficulty,
                        items: _difficulties.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                          _filterExercises();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Equipment',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedEquipment,
                        items: _equipment.map((equipment) {
                          return DropdownMenuItem(
                            value: equipment,
                            child: Text(equipment),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEquipment = value!;
                          });
                          _filterExercises();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Import Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _importGymVisualExercises,
              icon: const Icon(Icons.download),
              label: const Text('Import GymVisual Exercises'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Exercise Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filteredExercises.length} of ${_exercises.length} exercises',
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Source: GymVisual.com',
                  style: TextStyle(
                    color: TColor.primaryColor1,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Exercises List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExercises.isEmpty
                    ? const Center(
                        child: Text('No exercises found'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: TColor.lightGray,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Colors.grey,
                                ),
                              ),
                              title: Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: exercise.muscleGroups.map((muscle) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: TColor.primaryColor1.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          muscle,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: TColor.primaryColor1,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // TODO: Navigate to exercise detail screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Selected: ${exercise.name}'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 