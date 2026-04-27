import 'dart:convert';
import 'dart:io';

import 'matchup_record.dart';

/// Pro maclardan toplanan matchup verilerinin lokal JSON DB'si.
/// Native (CLI / desktop) icin dosya tabanli. Web entegrasyonu Faz 3.1.
class MatchupStore {
  final File _file;

  MatchupStore({File? file})
      : _file = file ?? File('.cache/matchups.json') {
    if (!_file.parent.existsSync()) _file.parent.createSync(recursive: true);
  }

  Map<String, dynamic> _readDoc() {
    if (!_file.existsSync()) {
      return {'records': <Map<String, dynamic>>[], 'updatedAt': null};
    }
    try {
      return jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      return {'records': <Map<String, dynamic>>[], 'updatedAt': null};
    }
  }

  List<MatchupRecord> readAll() {
    final doc = _readDoc();
    final list = (doc['records'] as List? ?? []).cast<Map<String, dynamic>>();
    return list.map(MatchupRecord.fromJson).toList();
  }

  /// Yeni kayitlari mevcutlarla birlestir (id ile dedupe). Eklenen sayiyi don.
  int addAll(List<MatchupRecord> newRecords) {
    final doc = _readDoc();
    final existing = (doc['records'] as List? ?? []).cast<Map<String, dynamic>>();
    final byId = <String, Map<String, dynamic>>{
      for (final r in existing) (r['id'] as String? ?? _idFromJson(r)): r,
    };
    var added = 0;
    for (final r in newRecords) {
      if (byId.containsKey(r.id)) continue;
      final json = r.toJson();
      json['id'] = r.id;
      byId[r.id] = json;
      added++;
    }
    doc['records'] = byId.values.toList();
    doc['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    _file.writeAsStringSync(jsonEncode(doc));
    return added;
  }

  String _idFromJson(Map<String, dynamic> r) {
    final t = r['battleTime'] as String? ?? '';
    final tag = r['winnerTag'] as String? ?? '';
    final wc = (r['winnerCards'] as List).join(',');
    final lc = (r['loserCards'] as List).join(',');
    return '$t|$tag|$wc|$lc';
  }

  DateTime? get lastUpdated {
    final raw = _readDoc()['updatedAt'] as String?;
    return raw == null ? null : DateTime.parse(raw);
  }

  int get count => readAll().length;
}
