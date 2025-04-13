// lib/core/providers/analytics_provider.dart

import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:workout_tracker/features/analytics/widgets/time_filter_selector.dart';
import '../models/workout.dart';
import 'workout_provider.dart';

class AnalyticsProvider with ChangeNotifier {
  final WorkoutProvider _workoutProvider;
  final TimeFilterProvider timeFilterProvider;

  String? _selectedExerciseId;
  String? _selectedMuscleGroup;

  AnalyticsProvider(this._workoutProvider, this.timeFilterProvider) {
    // Listen to workout and time filter changes
    _workoutProvider.addListener(() {
      notifyListeners();
    });
    timeFilterProvider.addListener(() {
      notifyListeners();
    });
  }

  // Getters
  String? get selectedExerciseId => _selectedExerciseId;
  String? get selectedMuscleGroup => _selectedMuscleGroup;

  // Setters
  void setSelectedExerciseId(String? exerciseId) {
    _selectedExerciseId = exerciseId;
    notifyListeners();
  }

  void setSelectedMuscleGroup(String? muscleGroup) {
    _selectedMuscleGroup = muscleGroup;
    notifyListeners();
  }

  // Analytics data getters
  List<FlSpot> getExerciseProgressChartData() {
    if (_selectedExerciseId == null) return [];

    final data = getExerciseProgressData(_selectedExerciseId!);

    // Transform to FL chart spots
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['weight'] as double);
    }).toList();
  }

  List<Map<String, dynamic>> getExerciseProgressData(String exerciseId) {
    final workouts = getFilteredWorkouts();
    final result = <Map<String, dynamic>>[];

    // Find workouts containing this exercise
    final workoutsWithExercise = workouts.where((w) =>
        w.exercises.any((e) => e.exerciseId == exerciseId)).toList();

    // Sort by date
    workoutsWithExercise.sort((a, b) => a.date.compareTo(b.date));

    for (var workout in workoutsWithExercise) {
      final exercise = workout.exercises.firstWhere(
        (e) => e.exerciseId == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );

      if (exercise.sets.isNotEmpty) {
        // Find maximum weight used in the exercise
        final maxWeightSet = exercise.sets.reduce((curr, next) =>
            curr.weight > next.weight ? curr : next);

        // Track both max weight and total volume
        double totalVolume = 0;
        for (final set in exercise.sets) {
          totalVolume += (set.weight * set.reps);
        }

        result.add({
          'date': workout.date,
          'weight': maxWeightSet.weight,
          'reps': maxWeightSet.reps,
          'totalVolume': totalVolume,
          'formattedDate': DateFormat('MMM d').format(workout.date),
        });
      }
    }

    return result;
  }

  Map<String, double> getMuscleGroupDistribution() {
    final workouts = getFilteredWorkouts();
    final distribution = <String, double>{};

    // Count exercises by muscle group
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        if (distribution.containsKey(exercise.muscleGroup)) {
          distribution[exercise.muscleGroup] =
              distribution[exercise.muscleGroup]! + 1;
        } else {
          distribution[exercise.muscleGroup] = 1;
        }
      }
    }

    return distribution;
  }

  List<Map<String, dynamic>> getWorkoutFrequencyData() {
    final workouts = getFilteredWorkouts();
    final frequency = <String, int>{};

    // Group workouts by day of week
    for (var workout in workouts) {
      final dayName = DateFormat('EEEE').format(workout.date);
      if (frequency.containsKey(dayName)) {
        frequency[dayName] = frequency[dayName]! + 1;
      } else {
        frequency[dayName] = 1;
      }
    }

    // Convert to list format
    return frequency.entries.map((entry) => {
          'day': entry.key,
          'count': entry.value,
        }).toList();
  }

  List<Map<String, dynamic>> getMonthlyWorkoutCounts() {
    final workouts = getFilteredWorkouts();
    final counts = <String, int>{};

    // Group workouts by month
    for (var workout in workouts) {
      final monthKey = DateFormat('yyyy-MM').format(workout.date);
      final readableMonth = DateFormat('MMM yyyy').format(workout.date);

      if (counts.containsKey(monthKey)) {
        counts[monthKey] = counts[monthKey]! + 1;
      } else {
        counts[monthKey] = 1;
      }
    }

    // Convert to sorted list format
    final entries = counts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries.map((entry) {
      final dateParts = entry.key.split('-');
      final date = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]));
      return {
        'month': DateFormat('MMM yyyy').format(date),
        'count': entry.value,
      };
    }).toList();
  }

  double getTotalWeightLifted() {
    final workouts = getFilteredWorkouts();
    return workouts.fold(0, (sum, workout) => sum + workout.totalWeightLifted);
  }

  int getTotalWorkoutCount() {
    return getFilteredWorkouts().length;
  }

  Map<String, dynamic> getMostTrainedExercise() {
    final workouts = getFilteredWorkouts();
    final exerciseCounts = <String, Map<String, dynamic>>{};

    // Count how many times each exercise appears
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        if (exerciseCounts.containsKey(exercise.exerciseId)) {
          exerciseCounts[exercise.exerciseId]!['count'] += 1;
        } else {
          exerciseCounts[exercise.exerciseId] = {
            'id': exercise.exerciseId,
            'name': exercise.exerciseName,
            'muscleGroup': exercise.muscleGroup,
            'count': 1,
          };
        }
      }
    }

    if (exerciseCounts.isEmpty) {
      return {'name': 'None', 'count': 0, 'muscleGroup': ''};
    }

    // Find exercise with highest count
    final mostTrainedEntry = exerciseCounts.entries
        .reduce((a, b) => a.value['count'] > b.value['count'] ? a : b);

    return mostTrainedEntry.value;
  }

  // Helper methods
  List<Workout> getFilteredWorkouts() {
    final range = timeFilterProvider.dateRange;
    return _workoutProvider.getFilteredWorkouts(range);
  }
}
