import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';

import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/models/exercise.dart';
import 'core/models/workout.dart';
import 'core/models/workout_set.dart';
import 'core/models/user_settings.dart';
import 'core/providers/workout_provider.dart';
import 'core/providers/exercise_provider.dart';
import 'core/providers/analytics_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/notification_service.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'package:workout_tracker/features/analytics/providers/time_filter_provider.dart';
import 'package:workout_tracker/features/dashboard/providers/dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive first
  await initializeHive();

  // Then request permissions
  await _requestPermissions();

  // Initialize notifications
  await NotificationService().initNotification();

  runApp(MyApp());
}

Future<void> initializeHive() async {
  try {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkoutSetAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(WorkoutExerciseAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    // Open boxes with error handling and recovery
    await Hive.openBox<Exercise>('exercises').catchError((e) async {
      await Hive.deleteBoxFromDisk('exercises');
      await Hive.openBox<Exercise>('exercises');
    });
    await Hive.openBox<Workout>('workouts').catchError((e) async {
      await Hive.deleteBoxFromDisk('workouts');
      await Hive.openBox<Workout>('workouts');
    });
    await Hive.openBox<UserSettings>('settings').catchError((e) async {
      await Hive.deleteBoxFromDisk('settings');
      await Hive.openBox<UserSettings>('settings');
    });

    // Open a dummy box to check initialization in FutureBuilder
    await Hive.openBox('initCheck');
  } catch (e) {
    print("Hive initialization error: $e");
    // Optionally handle error or reset boxes if needed
  }
}

// Function to handle permission requests
Future<void> _requestPermissions() async {
  await Permission.notification.request();
  // Add other permissions if needed
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox('initCheck'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(child: Text('Error initializing app')),
              ),
            );
          }
          return _buildAppContent(context);
        }
        return MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildAppContent(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => TimeFilterProvider()),
        ChangeNotifierProvider(
          create: (context) => AnalyticsProvider(
            Provider.of<WorkoutProvider>(context, listen: false),
            Provider.of<TimeFilterProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardProvider(
            Provider.of<WorkoutProvider>(context, listen: false),
            Provider.of<ExerciseProvider>(context, listen: false),
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Workout Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            routes: AppRoutes.routes,
            initialRoute: '/dashboard', // Define the initial route
          );
        },
      ),
    );
  }
}