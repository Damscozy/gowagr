import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:gowagr/core/config/logger_service.dart';
import 'package:gowagr/data/model/event_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const _boxName = 'app_hive';
  static const _watchlistKey = 'event_ids';
  static const _cachedEventsKey = 'cachedEvents';
  static const _accessTokenKey = 'accessToken';

  static final _key = encrypt.Key.fromUtf8('16charslongkey!!');
  static final _iv = encrypt.IV.fromUtf8('16charslongiv!!!');
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static Box<dynamic> get _box => Hive.box(_boxName);

  static String get accessToken =>
      _box.get(_accessTokenKey, defaultValue: '') as String;
  static set accessToken(String value) => _box.put(_accessTokenKey, value);

  static Future<Set<String>> getWatchlist() async {
    final list = _box.get(_watchlistKey, defaultValue: <String>[]);
    return Set<String>.from(list);
  }

  static Future<void> toggleWatchlist(String eventId) async {
    final watchlist = Set<String>.from(
      _box.get(_watchlistKey, defaultValue: <String>[]),
    );

    if (watchlist.contains(eventId)) {
      watchlist.remove(eventId);
    } else {
      watchlist.add(eventId);
    }

    await _box.put(_watchlistKey, watchlist.toList());
  }

  static Future<bool> isInWatchlist(String eventId) async {
    final watchlist = await getWatchlist();
    return watchlist.contains(eventId);
  }

  static Future<void> saveEventsModel(EventsModel eventsModel) async {
    try {
      final jsonString = jsonEncode(eventsModel.toJson());
      final encrypted = _encrypter.encrypt(jsonString, iv: _iv).base64;

      await _box.put(_cachedEventsKey, encrypted);
      log.d('Saved ${eventsModel.events.length} encrypted events to Hive');
    } catch (e, s) {
      log.e('Failed to save events', error: e, stackTrace: s);
    }
  }

  static EventsModel? getCachedEventsModel() {
    final encrypted = _box.get(_cachedEventsKey);
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
    await _box.clear();
    for (final entry in retainedData.entries) {
      await _box.put(entry.key, entry.value);
    }
    log.d('Cleared all Hive data. Retained: $retainedData');
  }
}
