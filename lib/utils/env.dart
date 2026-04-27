// Web'de dart:io yok; --dart-define ile compile-time env desteklenir.
// Native (Windows/macOS/iOS/Android) tarafta .env dosyasi ve Platform env okunur.

import 'env_io.dart' if (dart.library.html) 'env_web.dart' as impl;

class Env {
  static String get crApiToken => impl.readEnv('CR_API_TOKEN') ??
      (throw StateError(
        'CR_API_TOKEN bulunamadı. .env dosyasına ekle veya '
        'web için --dart-define=CR_API_TOKEN=... ile gec.',
      ));

  static String? get crApiBaseUrl => impl.readEnv('CR_API_BASE_URL');
}
