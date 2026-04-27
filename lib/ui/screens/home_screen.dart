import 'package:flutter/material.dart';

import '../../data/api/cr_api_client.dart';
import '../../data/api/supercell_api_client.dart';
import '../../data/cache/battle_cache_factory.dart';
import '../../data/cache/meta_cache_factory.dart';
import '../../data/card_catalog.dart';
import '../../data/harvest/matchup_asset_loader.dart';
import '../../data/meta_provider.dart';
import '../../data/meta_scraper.dart';
import '../../engine/opponent_analyzer.dart';
import '../../utils/env.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tagController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Bir oyuncu tag\'i gir (#XXXXXXXX).');
      return;
    }
    final tag = raw.startsWith('#') ? raw : '#$raw';

    setState(() {
      _loading = true;
      _error = null;
    });

    SupercellApiClient? client;
    try {
      client = SupercellApiClient(
        token: Env.crApiToken,
        baseUrl: Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl,
      );
      // Kart katalogunu yükle (ilk analizde bir kez, sonra cache'lenir).
      await CardCatalog.load(client);
      final analyzer = OpponentAnalyzer(client, cache: createBattleCache());
      final analysis = await analyzer.analyze(tag);

      // Guncel meta destelerini yukle (6 saatlik cache).
      final metaProvider = MetaProvider(
        scraper: MetaScraper(availableCardNames: CardCatalog.allNames),
        cache: createMetaCache(),
      );
      final metaDecks = await metaProvider.load();

      // Pro mac matchup veritabanini yukle (asset bundle).
      final matchupRecords = await MatchupAssetLoader.load();

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SummaryScreen(
            analysis: analysis,
            metaPool: metaDecks,
            matchupRecords: matchupRecords,
          ),
        ),
      );
    } on CRApiException catch (e) {
      setState(() {
        _error = e.statusCode == 404
            ? 'Oyuncu bulunamadı: $tag'
            : 'API hatası (${e.statusCode}): ${e.message}';
      });
    } catch (e) {
      setState(() => _error = 'Hata: $e');
    } finally {
      await client?.dispose();
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CR Analyze — Anti-Deck'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.shield_moon,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Rakip oyuncu tag\'ini gir',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Son maçlarına bakıp en çok kullandığı desteleri çıkaracağız.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _tagController,
                  enabled: !_loading,
                  decoration: const InputDecoration(
                    hintText: '#XXXXXXXX',
                    prefixIcon: Icon(Icons.tag),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _analyze(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading ? null : _analyze,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_loading ? 'Analiz ediliyor...' : 'Analiz Et'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
