import 'package:intl/intl.dart';

class AppHelpers {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime.toLocal());
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  static String pluralize(int count, String singular, [String? plural]) {
    if (count == 1) return '$count $singular';
    return '$count ${plural ?? '${singular}s'}';
  }

  static String getVotePercentage(int votes, int totalVotes) {
    if (totalVotes == 0) return '0.0%';
    return '${((votes / totalVotes) * 100).toStringAsFixed(1)}%';
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return capitalize(status);
    }
  }
}
