import 'dart:convert';
import 'dart:io';

import '../static/meta_decks.dart';
import 'meta_cache.dart';
import 'meta_cache_codec.dart';

MetaCache createMetaCache() => FileMetaCache();

class FileMetaCache implements MetaCache {
  final File _file;

  FileMetaCache({File? file})
      : _file = file ?? File('.cache/meta_decks.json') {
    final dir = _file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
  }

  @override
  Future<List<MetaDeck>?> read(
      {Duration ttl = const Duration(hours: 6)}) async {
    if (!_file.existsSync()) return null;
    try {
      final doc = jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;
      final ts = DateTime.tryParse(doc['savedAt'] as String? ?? '');
      if (ts == null) return null;
      if (DateTime.now().toUtc().difference(ts.toUtc()) > ttl) return null;
      final list = (doc['decks'] as List).cast<Map<String, dynamic>>();
      return list.map(metaDeckFromJson).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(List<MetaDeck> decks) async {
    final doc = {
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'decks': decks.map(metaDeckToJson).toList(),
    };
    _file.writeAsStringSync(jsonEncode(doc));
  }
}
