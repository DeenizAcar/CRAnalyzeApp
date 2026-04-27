import 'package:flutter/material.dart';

import '../../data/harvest/matchup_record.dart';
import '../../data/static/meta_decks.dart';
import '../../engine/matchup_engine.dart';
import '../../engine/matchup_scorer.dart';
import '../../engine/opponent_analyzer.dart';
import '../../engine/recommendation_engine.dart';
import '../../engine/rule_based_engine.dart';
import '../../engine/vulnerability_analyzer.dart';
import '../../engine/win_condition.dart';
import '../widgets/anti_deck_block.dart';
import '../widgets/deck_card.dart';
import '../widgets/vulnerability_block.dart';

class DetailScreen extends StatelessWidget {
  final OpponentAnalysis analysis;
  final List<MetaDeck>? metaPool;
  final List<MatchupRecord>? matchupRecords;

  const DetailScreen({
    super.key,
    required this.analysis,
    this.metaPool,
    this.matchupRecords,
  });

  RecommendationEngine _buildEngine() {
    final pool = metaPool;
    final records = matchupRecords;
    if (pool != null && records != null && records.isNotEmpty) {
      return MatchupEngine(pool: pool, scorer: MatchupScorer(records));
    }
    return RuleBasedEngine(pool: pool);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = analysis.profile;
    final engine = _buildEngine();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detaylı Analiz: ${p.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                p.tag,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (engine is MatchupEngine && analysis.deckUsages.length > 1) ...[
            _CombinedRecommendationBlock(
              recommendations: engine.recommendCombined(
                opponentDecks: analysis.deckUsages
                    .map((u) => (deck: u.deck, weight: u.count))
                    .toList(),
                maxResults: 3,
              ),
              opponentDeckCount: analysis.deckUsages.length,
            ),
            const SizedBox(height: 16),
          ],
          if (analysis.deckUsages.isNotEmpty) ...[
            VulnerabilityBlock(
              missing: VulnerabilityAnalyzer.commonMissingCategories(
                analysis.deckUsages.map((u) => u.deck).toList(),
              ),
              weak: VulnerabilityAnalyzer.commonWeakCategories(
                analysis.deckUsages.map((u) => u.deck).toList(),
              ),
              opponentDeckCount: analysis.deckUsages.length,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            '${analysis.totalBattles} ranked maçtaki desteler',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (analysis.deckUsages.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Görüntülenecek deste yok.')),
            )
          else
            ...analysis.deckUsages.expand((u) {
              final losses = u.count - u.wins;
              final winCond = detectWinCondition(u.deck);
              final recs = engine.recommendForDeck(u.deck, maxResults: 5);
              return [
                DeckCardWidget(
                  deck: u.deck,
                  title: '${u.count} kez kullanıldı  (W:${u.wins} L:$losses)',
                ),
                AntiDeckBlock(
                  recommendations: recs,
                  winCondition: winCond,
                ),
              ];
            }),
        ],
      ),
    );
  }
}

class _CombinedRecommendationBlock extends StatelessWidget {
  final List<DeckRecommendation> recommendations;
  final int opponentDeckCount;

  const _CombinedRecommendationBlock({
    required this.recommendations,
    required this.opponentDeckCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B4E), Color(0xFF1A2138)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC107), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium,
                  color: Color(0xFFFFC107), size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hepsine karşı tek deste önerisi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFC107),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rakibin $opponentDeckCount farklı destesine karşı en iyi performansı veren tek deste:',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          if (recommendations.isEmpty)
            Text(
              'Yeterli pro maç verisi bulunamadı.',
              style: theme.textTheme.bodySmall,
            )
          else
            AntiDeckBlock(
              recommendations: recommendations,
              showHeader: false,
            ),
        ],
      ),
    );
  }
}
