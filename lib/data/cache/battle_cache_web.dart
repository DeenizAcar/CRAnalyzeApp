// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

import '../api/supercell_api_client.dart';
import 'battle_cache.dart';

BattleCache createBattleCache() => LocalStorageBattleCache();

class LocalStorageBattleCache implements BattleCache {
  String _key(String tag) =>
      'crAnalyze.battles.${tag.replaceAll('#', '').replaceAll(RegExp(r'[^A-Z0-9]'), '')}';

  Map<String, dynamic>? _readDoc(String tag) {
    final raw = html.window.localStorage[_key(tag)];
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _writeDoc(String tag, Map<String, dynamic> doc) {
    html.window.localStorage[_key(tag)] = jsonEncode(doc);
  }

  @override
  Future<List<Map<String, dynamic>>> read(String tag) async {
    final doc = _readDoc(tag);
    if (doc == null) return const [];
    final battles = (doc['battles'] as List? ?? []).cast<Map<String, dynamic>>();
    final sorted = [...battles];
    sorted.sort((a, b) {
      final ta = a['battleTime'] as String? ?? '';
      final tb = b['battleTime'] as String? ?? '';
      return tb.compareTo(ta);
    });
    return sorted;
  }

  @override
  Future<int> merge(String tag, List<Map<String, dynamic>> incoming) async {
    final doc = _readDoc(tag) ?? <String, dynamic>{'battles': <Map<String, dynamic>>[]};
    final existing = (doc['battles'] as List? ?? []).cast<Map<String, dynamic>>().toList();
    final byId = <String, Map<String, dynamic>>{
      for (final b in existing) SupercellApiClient.battleIdFromRaw(b): b,
    };
    var added = 0;
    for (final b in incoming) {
      final id = SupercellApiClient.battleIdFromRaw(b);
      if (!byId.containsKey(id)) {
        byId[id] = b;
        added++;
      }
    }
    doc['battles'] = byId.values.toList();
    doc['lastUpdated'] = DateTime.now().toUtc().toIso8601String();
    _writeDoc(tag, doc);
    return added;
  }

  @override
  Future<DateTime?> lastUpdated(String tag) async {
    final doc = _readDoc(tag);
    final raw = doc?['lastUpdated'] as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }

  @override
  Future<void> clear(String tag) async {
    html.window.localStorage.remove(_key(tag));
  }
}
