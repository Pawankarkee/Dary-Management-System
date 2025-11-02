import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// A simple in-app mock server that stores posted items in Hive boxes
/// named `server_<type>`. This lets us simulate push and pull without
/// an external HTTP server.
class MockServerService {
  /// Post an item to the mock server.
  /// If [fileBytes] is provided it will be stored in the record as a
  /// base64 string under `photoBytes`.
  static Future<void> postItem(
    String type,
    Map<String, dynamic> payload, {
    List<int>? fileBytes,
  }) async {
    final boxName = 'server_$type';
    final box = await Hive.openBox(boxName);

    final id = payload['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final record = Map<String, dynamic>.from(payload);
    record['server_timestamp'] = DateTime.now().toIso8601String();

    if (fileBytes != null) {
      record['photoBytes'] = base64Encode(fileBytes);
    }

    await box.put(id, record);
  }

  /// Fetch all records of a given type from the mock server.
  /// If [since] is provided only records newer than [since] are returned.
  static Future<List<Map<String, dynamic>>> fetchUpdates(
    String type, {
    DateTime? since,
  }) async {
    final boxName = 'server_$type';
    final box = await Hive.openBox(boxName);
    final results = <Map<String, dynamic>>[];

    for (var value in box.values) {
      final rec = Map<String, dynamic>.from(value);
      if (since != null && rec['server_timestamp'] != null) {
        final ts = DateTime.tryParse(rec['server_timestamp']);
        if (ts != null && ts.isBefore(since)) continue;
      }
      results.add(rec);
    }

    return results;
  }

  /// Clear mock server data for a type or all server boxes when type is null.
  static Future<void> clearServerData([String? type]) async {
    if (type != null) {
      final box = await Hive.openBox('server_$type');
      await box.clear();
      return;
    }

    // clear common server boxes used by the app
    final names = [
      'server_farmer',
      'server_milk_collection',
      'server_transaction',
      'server_product',
    ];

    for (var name in names) {
      final box = await Hive.openBox(name);
      await box.clear();
    }
  }
}
