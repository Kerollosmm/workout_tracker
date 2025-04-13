// lib/core/providers/time_filter_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TimeFilterProvider with ChangeNotifier {
  String _currentFilter = 'Weekly'; // Daily, Weekly, Monthly, Yearly, All Time
  DateTimeRange? _customDateRange;

  String get currentFilter => _currentFilter;
  DateTimeRange? get customDateRange => _customDateRange;

  void setFilter(String filter) {
    _currentFilter = filter;
    _customDateRange = null;
    notifyListeners();
  }

  void setCustomDateRange(DateTimeRange range) {
    _currentFilter = 'Custom';
    _customDateRange = range;
    notifyListeners();
  }

  DateTimeRange get dateRange {
    final now = DateTime.now();
    switch (_currentFilter) {
      case 'Daily':
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case 'Weekly':
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case 'Monthly':
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, now.day),
          end: now,
        );
      case 'Yearly':
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, now.day),
          end: now,
        );
      case 'Custom':
        return _customDateRange!;
      default: // All Time
        return DateTimeRange(
          start: DateTime(2000),
          end: now,
        );
    }
  }
}  