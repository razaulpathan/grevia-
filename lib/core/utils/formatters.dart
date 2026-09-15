import 'package:intl/intl.dart';

/// Formatting utilities for Phone Numbers, Dates, Times, and File Sizes
class Formatters {
  Formatters._();

  /// Normalize phone number to E.164 format (e.g. +1234567890)
  static String normalizePhoneNumber(String rawPhone,
      {String defaultCountryCode = '+1'}) {
    var cleaned = rawPhone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('00')) {
        cleaned = '+${cleaned.substring(2)}';
      } else {
        cleaned = '$defaultCountryCode$cleaned';
      }
    }
    return cleaned;
  }

  /// Format last seen status: "online", "last seen 5m ago", "last seen yesterday at 14:20"
  static String formatLastSeen({required bool isOnline, DateTime? lastSeen}) {
    if (isOnline) return 'online';
    if (lastSeen == null) return 'offline';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && now.day == lastSeen.day) {
      return 'last seen today at ${DateFormat('HH:mm').format(lastSeen)}';
    } else if (difference.inDays < 2) {
      return 'last seen yesterday at ${DateFormat('HH:mm').format(lastSeen)}';
    } else {
      return 'last seen on ${DateFormat('MMM dd').format(lastSeen)}';
    }
  }

  /// Format chat message timestamp: "14:25" or "Yesterday" or "12/04/2026"
  static String formatChatListTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (now.day == dateTime.day &&
        now.month == dateTime.month &&
        now.year == dateTime.year) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 2 && now.day - dateTime.day == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // Day name, e.g. "Monday"
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  /// Format duration in seconds to "mm:ss" or "hh:mm:ss"
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format bytes to human-readable string (KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
