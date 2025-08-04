import 'dart:io';

import 'package:logger/logger.dart';

final log = Logger(printer: PrettyPrinter());

class LoggerService {
  static final log = Logger(printer: PrettyPrinter());

  static void logInfo(String message) {
    log.i(message);
  }

  static void logError({
    required error,
    StackTrace? stackTrace,
    String? reason,
    dynamic errorCode,
  }) async {
    log.e(
      error.toString(),
      stackTrace: stackTrace,
      error: error,
    );
    try {
      // await FirebaseCrashlytics.instance.recordError(
      //   error,
      //   stackTrace,
      //   reason: reason != null
      //       ? "${errorCode ?? 'unknown'},Device:$deviceType -$reason"
      //       : 'unknown error,',
      //   fatal: true,
      // );
    } catch (e) {
      log.e(e.toString());
    }
  }

  static void logWarning(String message) {
    log.w(message);
  }

  static void d(String message) {
    log.d(message);
  }

  static String get deviceType {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else {
      return 'Unknown';
    }
  }
}
