import 'dart:convert';

extension MapExtension<K, V> on Map<K, V> {
  Map<K, V> get removeNullValues {
    return Map<K, V>.fromEntries(entries.where((e) => e.value != null));
  }
}

String formatCurrency(bool isNGN, num value) {
  final currencySymbol = isNGN ? "₦" : "\$";

  // If >= 1000, show in 'k' format
  if (value >= 1000) {
    return "$currencySymbol${(value / 1000).toStringAsFixed(0)}k";
  }
  return "$currencySymbol${value.toStringAsFixed(0)}";
}

String monthName(int month) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  return months[month];
}

String? parseResponseMessage(dynamic message) {
  if (message == null) return null;

  String messageStr = message.toString().trim();

  try {
    final decoded = jsonDecode(messageStr);

    if (decoded is List && decoded.every((e) => e is String)) {
      return decoded.join('\n');
    }

    if (decoded is Map<String, dynamic> && decoded['errors'] is List) {
      final errors = decoded['errors'] as List;

      final messages = errors
          .where((e) => e is Map && e.containsKey('message'))
          .map((e) => e['message'].toString())
          .toSet()
          .toList();

      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    return messageStr.replaceAll(RegExp(r'^\[|\]$'), '');
  } catch (e) {
    return messageStr.replaceAll(RegExp(r'^\[|\]$'), '');
  }
}
