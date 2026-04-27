// Web'de localStorage, native'de dosya kullanir.

import 'battle_cache.dart';
import 'battle_cache_io.dart' if (dart.library.html) 'battle_cache_web.dart' as impl;

BattleCache createBattleCache() => impl.createBattleCache();
