import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:gowagr/core/config/logger_service.dart';
import 'package:gowagr/data/model/event_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const _mainBoxName = 'app_hive';
  static const _eventsBoxName = 'events';
  static const _cachedEventsKey = 'cachedEvents';

  static final _key = encrypt.Key.fromUtf8('16charslongkey!!');
  static final _iv = encrypt.IV.fromUtf8('16charslongiv!!!');
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static Box<dynamic> box() => Hive.box(_mainBoxName);

  static String get accessToken =>
      box().get('accessToken', defaultValue: '') as String;
  static set accessToken(String value) => box().put('accessToken', value);

  static Future<void> saveEventsModel(EventsModel eventsModel) async {
    try {
      final eventsBox = await Hive.openBox(_eventsBoxName);
      final jsonString = jsonEncode(eventsModel.toJson());
      final encrypted = _encrypter.encrypt(jsonString, iv: _iv).base64;

      await eventsBox.put(_cachedEventsKey, encrypted);
      log.d('Saved ${eventsModel.events.length} encrypted events to Hive');
    } catch (e, s) {
      log.e('Failed to save events', error: e, stackTrace: s);
    }
  }

  static EventsModel? getCachedEventsModel() {
    if (!Hive.isBoxOpen(_eventsBoxName)) return null;

    final eventsBox = Hive.box(_eventsBoxName);
    final encrypted = eventsBox.get(_cachedEventsKey);
    if (encrypted == null) return null;

    try {
      final decryptedJson = _encrypter.decrypt64(encrypted, iv: _iv);
      final decoded = Map<String, dynamic>.from(jsonDecode(decryptedJson));
      return EventsModel.fromJson(decoded);
    } catch (e, s) {
      log.e('Failed to decrypt events', error: e, stackTrace: s);
      return null;
    }
  }

  /// One-line helper: cache events only if they are valid and not stale
  static Future<void> cacheEventsIfFresh(EventsModel? newData) async {
    if (newData == null || (newData.events.isEmpty)) {
      log.d('Skipping cache: No events to save');
      return;
    }

    final cached = getCachedEventsModel();
    if (cached != null &&
        jsonEncode(cached.toJson()) == jsonEncode(newData.toJson())) {
      log.d('Skipping cache: Events are identical to existing cache');
      return;
    }

    await saveEventsModel(newData);
  }

  static Future<void> clearAllData() async {
    final retainedData = <String, dynamic>{};
    await box().clear();
    for (final entry in retainedData.entries) {
      await box().put(entry.key, entry.value);
    }
    log.d('Cleared all Hive data. Retained: $retainedData');
  }
}
