// lib/features/dashboard/widgets/workout_summary_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker/config/constants/app_constants.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/models/workout.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/workout_provider.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutSummaryCard({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workoutsByDate = Provider.of<WorkoutProvider>(context).workoutsByDate;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: workoutsByDate.length,
      itemBuilder: (context, index) {
        final date = workoutsByDate.keys.elementAt(index);
        final workouts = workoutsByDate[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat.yMMMd().format(date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...workouts.map((workout) => WorkoutSummaryCard(
                  workout: workout,
                  onTap: () {
                    // Handle card tap
                  },
                )),
          ],
        );
      },
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
