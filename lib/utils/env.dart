import 'dart:io';

class Env {
  static String get crApiToken {
    final fromEnv = Platform.environment['CR_API_TOKEN'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

    final file = File('.env');
    if (file.existsSync()) {
      for (final line in file.readAsLinesSync()) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eq = trimmed.indexOf('=');
        if (eq < 0) continue;
        final key = trimmed.substring(0, eq).trim();
        final value = trimmed.substring(eq + 1).trim();
        if (key == 'CR_API_TOKEN') return value;
      }
    }
    throw StateError(
      'CR_API_TOKEN bulunamadı. .env dosyasına ekle veya environment variable olarak set et.',
    );
  }
}
