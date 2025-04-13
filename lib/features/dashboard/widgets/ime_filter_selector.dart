// lib/core/widgets/time_filter_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker/features/analytics/widgets/time_filter_selector.dart';

class TimeFilterSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeFilterProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(context, 'Daily', provider),
            _buildFilterChip(context, 'Weekly', provider),
            _buildFilterChip(context, 'Monthly', provider),
            _buildFilterChip(context, 'Yearly', provider),
            _buildFilterChip(context, 'All Time', provider),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => _showDateRangePicker(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, TimeFilterProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: provider.currentFilter == label,
        onSelected: (selected) {
          if (selected) provider.setFilter(label);
        },
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final provider = Provider.of<TimeFilterProvider>(context, listen: false);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setCustomDateRange(picked);
    }
  }
}