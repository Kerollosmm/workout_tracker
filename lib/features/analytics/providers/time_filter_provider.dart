import 'package:flutter/material.dart';
//lib\features\analytics\providers\time_filter_provider.dart
class TimeFilterProvider with ChangeNotifier {
  DateTimeRange _dateRange;

  TimeFilterProvider()
      : _dateRange = _defaultWeekRange();

  static DateTimeRange _defaultWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return DateTimeRange(start: startOfWeek, end: endOfWeek);
  }

  DateTimeRange get dateRange => _dateRange;

  void setDateRange(DateTimeRange range) {
    _dateRange = range;
    notifyListeners();
  }

  void setToday() {
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    notifyListeners();
  }

  void setThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    _dateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);
    notifyListeners();
  }

  void setThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    _dateRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
    notifyListeners();
  }

  void refreshFilters() {
    // Re-apply current filter to force refresh of filtered data
    final currentRange = _dateRange;
    setDateRange(currentRange);
  }
}
