import 'dart:convert';
import 'dart:io';

import '../api/supercell_api_client.dart';
import 'battle_cache.dart';

BattleCache createBattleCache() => FileBattleCache();

class FileBattleCache implements BattleCache {
  final Directory _dir;

  FileBattleCache({Directory? dir})
      : _dir = dir ?? Directory('.cache/battles') {
    if (!_dir.existsSync()) _dir.createSync(recursive: true);
  }

  String _safeTag(String tag) =>
      tag.replaceAll('#', '').replaceAll(RegExp(r'[^A-Z0-9]'), '');

  File _fileFor(String tag) => File('${_dir.path}/${_safeTag(tag)}.json');

  Map<String, dynamic>? _readDoc(String tag) {
    final f = _fileFor(tag);
    if (!f.existsSync()) return null;
    try {
      return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _writeDoc(String tag, Map<String, dynamic> doc) {
    _fileFor(tag).writeAsStringSync(jsonEncode(doc));
  }

  @override
  Future<List<Map<String, dynamic>>> read(String tag) async {
    final doc = _readDoc(tag);
    if (doc == null) return const [];
    final battles = (doc['battles'] as List? ?? []).cast<Map<String, dynamic>>();
    return _sortNewestFirst(battles);
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
    final f = _fileFor(tag);
    if (f.existsSync()) await f.delete();
  }

  static List<Map<String, dynamic>> _sortNewestFirst(
    List<Map<String, dynamic>> battles,
  ) {
    final sorted = [...battles];
    sorted.sort((a, b) {
      final ta = a['battleTime'] as String? ?? '';
      final tb = b['battleTime'] as String? ?? '';
      return tb.compareTo(ta);
    });
    return sorted;
  }
}
