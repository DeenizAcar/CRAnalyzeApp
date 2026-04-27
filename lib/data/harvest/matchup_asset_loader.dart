import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'matchup_record.dart';

/// Flutter assets'inden matchup veritabanini okur. Hem web hem native'de calisir.
class MatchupAssetLoader {
  static const String _assetPath = 'assets/data/matchups.json';

  static List<MatchupRecord>? _cached;

  static Future<List<MatchupRecord>> load() async {
    if (_cached != null) return _cached!;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final doc = jsonDecode(raw) as Map<String, dynamic>;
      final list = (doc['records'] as List? ?? []).cast<Map<String, dynamic>>();
      _cached = list.map(MatchupRecord.fromJson).toList(growable: false);
      return _cached!;
    } catch (_) {
      _cached = const [];
      return const [];
    }
  }
}
