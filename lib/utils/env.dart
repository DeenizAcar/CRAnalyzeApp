import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'env_native.dart' if (dart.library.html) 'env_web_stub.dart' as native;

/// Token / config okuyucu.
///
/// Akis:
/// 1. Flutter runtime'da `dotenv.env` dolu mu? (main.dart'ta load)
/// 2. Degilse: native taraftaki .env dosyasi / Platform.environment
///    (CLI tool'lari icin; UI cagirildiginda dotenv hep dolu olur)
/// 3. Yoksa --dart-define
class Env {
  static String get crApiToken => _read('CR_API_TOKEN') ??
      (throw StateError(
        'CR_API_TOKEN bulunamadı. .env dosyasını kök dizine koy '
        '(repo root: c:/GitHub/CRAnalyzeApp/.env).',
      ));

  static String? get crApiBaseUrl => _read('CR_API_BASE_URL');

  static String? _read(String key) {
    if (dotenv.isInitialized) {
      final v = dotenv.maybeGet(key);
      if (v != null && v.isNotEmpty) return v;
    }
    final fromNative = native.readEnv(key);
    if (fromNative != null && fromNative.isNotEmpty) return fromNative;
    final fromDefine = _readDefine(key);
    if (fromDefine != null && fromDefine.isNotEmpty) return fromDefine;
    return null;
  }

  static String? _readDefine(String key) {
    switch (key) {
      case 'CR_API_TOKEN':
        const v = String.fromEnvironment('CR_API_TOKEN');
        return v.isEmpty ? null : v;
      case 'CR_API_BASE_URL':
        const v = String.fromEnvironment('CR_API_BASE_URL');
        return v.isEmpty ? null : v;
    }
    return null;
  }
}
