import 'dart:io';

import 'package:logger/logger.dart';

final log = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

class LoggerService {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void logInfo(String message) {
    _logger.i("Adedamola ➜ $message");
  }

  static void logError({
    required dynamic error,
    StackTrace? stackTrace,
    String? reason,
    dynamic errorCode,
  }) {
    _logger.e(
      "Adedamola ❌ ${error.toString()}",
      stackTrace: stackTrace,
      error: error,
    );

    try {
      // Example: Crashlytics integration
      // await FirebaseCrashlytics.instance.recordError(
      //   error,
      //   stackTrace,
      //   reason: "${errorCode ?? 'unknown'}, Device: $deviceType - ${reason ?? ''}",
      //   fatal: true,
      // );
    } catch (e) {
      _logger.e("Adedamola ❌ Failed to send error to Crashlytics: $e");
    }
  }

  static void logWarning(String message) {
    _logger.w("Adedamola ⚠️ $message");
  }

  static void d(String message) {
    _logger.d("Adedamola 🛠 $message");
  }

  static String get deviceType {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }
}
