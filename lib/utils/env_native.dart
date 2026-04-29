// CLI tool'larin (dart run tool/...) Flutter binding'i olmadan kullandigi yol.
// UI runtime'da bu kullanilmaz cunku dotenv.load main.dart'ta yapilir.

import 'dart:io';

Map<String, String>? _cached;

Map<String, String> _load() {
  if (_cached != null) return _cached!;
  final result = <String, String>{};
  final file = File('.env');
  if (file.existsSync()) {
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq < 0) continue;
      final key = trimmed.substring(0, eq).trim();
      final value = trimmed.substring(eq + 1).trim();
      result[key] = value;
    }
  }
  _cached = result;
  return result;
}

String? readEnv(String key) {
  final fromPlatform = Platform.environment[key];
  if (fromPlatform != null && fromPlatform.isNotEmpty) return fromPlatform;
  final fromFile = _load()[key];
  if (fromFile != null && fromFile.isNotEmpty) return fromFile;
  return null;
}
