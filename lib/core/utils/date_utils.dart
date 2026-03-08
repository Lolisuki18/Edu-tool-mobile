import 'package:intl/intl.dart';

/// Helpers for formatting dates & timestamps returned by the API.
abstract final class DateUtils {
  static final _dayMonth = DateFormat('dd/MM/yyyy');
  static final _dayMonthTime = DateFormat('dd/MM/yyyy HH:mm');
  static final _iso = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// "25/03/2026"
  static String formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      return _dayMonth.format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  /// "25/03/2026 14:30"
  static String formatDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      return _dayMonthTime.format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  /// Converts a [DateTime] to ISO-8601 string.
  static String toIso(DateTime dt) => _iso.format(dt);

  /// Returns true when `endDate` is in the past.
  static bool isEnded(String? endDate) {
    if (endDate == null || endDate.isEmpty) return false;
    try {
      return DateTime.parse(endDate).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
