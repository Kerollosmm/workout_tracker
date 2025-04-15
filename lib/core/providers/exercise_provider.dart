import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';

class ExerciseProvider with ChangeNotifier {
  final Box<Exercise> _exercisesBox = Hive.box<Exercise>('exercises');
  final uuid = Uuid();
  bool _isInitialized = false;

  ExerciseProvider() {
    print("ExerciseProvider: Constructor called");
    // Don't call _ensureDefaultExercises() here
    // Instead, defer it to an async method
  }

  // Create a method to initialize data that can be called after widget is built
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print("ExerciseProvider: Starting initialization...");
      await _ensureDefaultExercises();
      _isInitialized = true;
      print("ExerciseProvider: Initialization complete");
      notifyListeners();
    } catch (e) {
      print("ExerciseProvider: Error during initialization: $e");
    }
  }

  Future<void> _ensureDefaultExercises() async {
    // Check if default exercises need to be added
    if (_exercisesBox.isEmpty) {
      await _addDefaultExercises();
    }
  }

  Future<void> _addDefaultExercises() async {
    final defaultExercises = [
      Exercise(
        id: uuid.v4(),
        name: 'Bench Press',
        muscleGroup: 'Chest',
        isCustom: false,
        iconPath: 'assets/icons/bench_press.png',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Squat',
        muscleGroup: 'Legs',
        isCustom: false,
        iconPath: 'assets/icons/squat.png',
      ),
      Exercise(
        id: uuid.v4(),
        name: 'Deadlift',
        muscleGroup: 'Back',
        isCustom: false,
        iconPath: 'assets/icons/deadlift.png',
      ),
      // Add more default exercises as needed
    ];

    for (final exercise in defaultExercises) {
      await _exercisesBox.add(exercise);
    }

    notifyListeners();
  }

  List<Exercise> get exercises => _exercisesBox.values.toList();

  List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  List<Exercise> get favoriteExercises =>
      exercises.where((e) => e.isFavorite).toList();

  Exercise? getExerciseById(String id) {
    try {
      return _exercisesBox.values.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addExercise(Exercise exercise) async {
    await _exercisesBox.add(exercise);
    notifyListeners();
  }

  Future<void> updateExercise(Exercise exercise) async {
    final index =
        _exercisesBox.values.toList().indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      await _exercisesBox.putAt(index, exercise);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final exercise = getExerciseById(id);
    if (exercise != null) {
      exercise.isFavorite = !exercise.isFavorite;
      await updateExercise(exercise);
    }
  }

  Future<void> deleteExercise(String id) async {
    final index =
        _exercisesBox.values.toList().indexWhere((e) => e.id == id);
    if (index != -1) {
      // Only allow deleting custom exercises
      final exercise = _exercisesBox.getAt(index);
      if (exercise != null && exercise.isCustom) {
        await _exercisesBox.deleteAt(index);
        notifyListeners();
      }
    }
  }

  List<String> get allMuscleGroups {
    return [
      'Chest',
      'Back',
      'Shoulders',
      'Arms',
      'Legs',
      'Core',
      'Cardio',
      'Full Body',
    ];
  }
}
