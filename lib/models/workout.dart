import 'exercise.dart';

class WorkoutSet {
  final int reps;
  final double? weight;
  final int? duration; // in seconds
  final bool completed;

  const WorkoutSet({
    required this.reps,
    this.weight,
    this.duration,
    this.completed = false,
  });

  WorkoutSet copyWith({
    int? reps,
    double? weight,
    int? duration,
    bool? completed,
  }) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'completed': completed,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'] as int,
      weight: json['weight'] as double?,
      duration: json['duration'] as int?,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class WorkoutExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final String? notes;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.notes,
  });

  WorkoutExercise copyWith({
    Exercise? exercise,
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List)
          .map(
            (setJson) => WorkoutSet.fromJson(setJson as Map<String, dynamic>),
          )
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

class Workout {
  final String id;
  final String name;
  final String? description;
  final List<WorkoutExercise> exercises;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool completed;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    this.startTime,
    this.endTime,
    this.completed = false,
  });

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    DateTime? startTime,
    DateTime? endTime,
    bool? completed,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((ex) => ex.toJson()).toList(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completed': completed,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List)
          .map(
            (exJson) =>
                WorkoutExercise.fromJson(exJson as Map<String, dynamic>),
          )
          .toList(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

// Sample workouts for demo purposes
class SampleWorkouts {
  static final List<Workout> workouts = [
    Workout(
      id: '1',
      name: 'Upper Body Strength',
      description: 'Focus on chest, shoulders, and arms',
      exercises: [
        WorkoutExercise(
          exercise: SampleExercises.exercises[0], // Push-ups
          sets: [
            const WorkoutSet(reps: 10),
            const WorkoutSet(reps: 8),
            const WorkoutSet(reps: 6),
          ],
        ),
      ],
    ),
    Workout(
      id: '2',
      name: 'Lower Body Power',
      description: 'Leg and glute focused workout',
      exercises: [
        WorkoutExercise(
          exercise: SampleExercises.exercises[1], // Squats
          sets: [
            const WorkoutSet(reps: 15),
            const WorkoutSet(reps: 12),
            const WorkoutSet(reps: 10),
          ],
        ),
      ],
    ),
    Workout(
      id: '3',
      name: 'Core Blast',
      description: 'Strengthen your core muscles',
      exercises: [
        WorkoutExercise(
          exercise: SampleExercises.exercises[2], // Plank
          sets: [
            const WorkoutSet(reps: 1, duration: 30),
            const WorkoutSet(reps: 1, duration: 45),
            const WorkoutSet(reps: 1, duration: 60),
          ],
        ),
      ],
    ),
  ];
}
