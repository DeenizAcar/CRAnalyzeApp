import 'meta_cache.dart';
import 'meta_cache_io.dart' if (dart.library.html) 'meta_cache_web.dart' as impl;

MetaCache createMetaCache() => impl.createMetaCache();
