import 'package:flutter/material.dart';

import '../../data/card_catalog.dart';
import '../../data/harvest/matchup_record.dart';
import '../../data/static/card_categories.dart';
import '../../data/static/meta_decks.dart';
import '../../engine/matchup_engine.dart';
import '../../engine/matchup_scorer.dart';
import '../../engine/opponent_analyzer.dart';
import '../../engine/recommendation_engine.dart';
import '../../engine/rule_based_engine.dart';
import '../../engine/vulnerability_analyzer.dart';
import '../widgets/card_picker_grid.dart';
import '../widgets/played_cards_summary.dart';
import 'detail_screen.dart';

class SummaryScreen extends StatefulWidget {
  final OpponentAnalysis analysis;
  final List<MetaDeck>? metaPool;
  final List<MatchupRecord>? matchupRecords;

  const SummaryScreen({
    super.key,
    required this.analysis,
    this.metaPool,
    this.matchupRecords,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final Set<String> _playedCards = {};

  RecommendationEngine _buildEngine() {
    final pool = widget.metaPool;
    final records = widget.matchupRecords;
    if (pool != null && records != null && records.isNotEmpty) {
      return MatchupEngine(pool: pool, scorer: MatchupScorer(records));
    }
    return RuleBasedEngine(pool: pool);
  }

  void _toggleCard(String name) {
    setState(() {
      if (_playedCards.contains(name)) {
        _playedCards.remove(name);
      } else {
        _playedCards.add(name);
      }
    });
  }

  void _clearPlayed() => setState(_playedCards.clear);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = widget.analysis;
    final p = analysis.profile;
    final engine = _buildEngine();

    final topRec = _resolveTopRecommendation(engine);
    final missing = VulnerabilityAnalyzer.commonMissingCategories(
      analysis.deckUsages.map((u) => u.deck).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                p.tag,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (analysis.deckUsages.isNotEmpty)
            _OpponentMiniPreview(deckUsages: analysis.deckUsages),
          const SizedBox(height: 14),
          if (topRec != null)
            _BigRecommendationCard(rec: topRec)
          else
            _EmptyRec(),
          const SizedBox(height: 14),
          if (missing.isNotEmpty)
            _CompactVulnerability(missing: missing)
          else if (analysis.deckUsages.isNotEmpty)
            _NoVulnerabilityNote(),
          const SizedBox(height: 14),
          PlayedCardsSummary(playedCards: _playedCards),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF12172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: CardPickerGrid(
              selectedNames: _playedCards,
              onToggle: _toggleCard,
              onClearAll: _clearPlayed,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailScreen(
                  analysis: widget.analysis,
                  metaPool: widget.metaPool,
                  matchupRecords: widget.matchupRecords,
                ),
              ),
            ),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Detaylı analiz'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A2138),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF8A2BE2), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  DeckRecommendation? _resolveTopRecommendation(RecommendationEngine engine) {
    final analysis = widget.analysis;
    if (analysis.deckUsages.isEmpty) return null;
    if (engine is MatchupEngine && analysis.deckUsages.length > 1) {
      final list = engine.recommendCombined(
        opponentDecks: analysis.deckUsages
            .map((u) => (deck: u.deck, weight: u.count))
            .toList(),
        maxResults: 1,
      );
      return list.isEmpty ? null : list.first;
    }
    final mostUsed = analysis.deckUsages.first.deck;
    final list = engine.recommendForDeck(mostUsed, maxResults: 1);
    return list.isEmpty ? null : list.first;
  }
}

class _OpponentMiniPreview extends StatelessWidget {
  final List<DeckUsage> deckUsages;
  const _OpponentMiniPreview({required this.deckUsages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mostUsed = deckUsages.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF12172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_search, size: 16, color: Colors.white60),
              const SizedBox(width: 6),
              Text(
                deckUsages.length > 1
                    ? 'Rakibin ana destesi (+${deckUsages.length - 1} alternatif)'
                    : 'Rakibin destesi',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: mostUsed.deck.cards
                .map((c) => _MiniIcon(name: c.name, isChampion: c.isChampion))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final String name;
  final bool isChampion;
  const _MiniIcon({required this.name, required this.isChampion});

  @override
  Widget build(BuildContext context) {
    final url = isChampion
        ? (CardCatalog.heroIconFor(name) ?? CardCatalog.iconFor(name))
        : CardCatalog.iconFor(name);
    return SizedBox(
      width: 32,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: url != null
            ? Image.network(url, fit: BoxFit.contain)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _BigRecommendationCard extends StatelessWidget {
  final DeckRecommendation rec;
  const _BigRecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scorePct = (rec.score * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B4E), Color(0xFF12172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFC107), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.25),
            blurRadius: 16,
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
                  color: Color(0xFFFFC107), size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bu desteyi al',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFC107),
                    fontSize: 22,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _scoreColor(scorePct).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _scoreColor(scorePct), width: 2),
                ),
                child: Text(
                  '%$scorePct',
                  style: TextStyle(
                    color: _scoreColor(scorePct),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rec.deck.slottedCards
                .map((slot) => _BigCardTile(slot: slot))
                .toList(),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights, size: 14, color: Colors.white60),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rec.reasoning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _scoreColor(int pct) {
    if (pct >= 70) return const Color(0xFF4CAF50);
    if (pct >= 50) return const Color(0xFFFFB300);
    return const Color(0xFF9E9E9E);
  }
}

class _BigCardTile extends StatelessWidget {
  final MetaCardSlot slot;
  static const double _w = 70;
  static const double _h = 88;
  const _BigCardTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final url = _resolveIcon();
    final borderColor = slot.isEvolution
        ? const Color(0xFFFFC107)
        : slot.isHero
            ? const Color(0xFFFF8A50)
            : Colors.white24;
    final w = slot.isEvolution || slot.isHero ? 2.0 : 1.0;

    return SizedBox(
      width: _w,
      height: _h,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: w),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: url != null
                  ? Image.network(url, fit: BoxFit.contain)
                  : Center(child: Text(slot.name, textAlign: TextAlign.center)),
            ),
            if (slot.isEvolution)
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(Icons.auto_awesome,
                    size: 14, color: Color(0xFFFFC107)),
              ),
          ],
        ),
      ),
    );
  }

  String? _resolveIcon() {
    if (slot.isEvolution) {
      return CardCatalog.evolutionIconFor(slot.name) ??
          CardCatalog.iconFor(slot.name);
    }
    if (slot.isHero) {
      return CardCatalog.heroIconFor(slot.name) ??
          CardCatalog.iconFor(slot.name);
    }
    return CardCatalog.iconFor(slot.name);
  }
}

class _CompactVulnerability extends StatelessWidget {
  final List<CardCategory> missing;
  const _CompactVulnerability({required this.missing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = missing.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1F0A), Color(0xFF12172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B00), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report_problem_outlined,
                  color: Color(0xFFFF8A50), size: 22),
              const SizedBox(width: 8),
              Text(
                'Rakibin açıkları',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFF8A50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...shown.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel,
                        color: Color(0xFFFF5252), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.tr} yok → ${c.exploit}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _NoVulnerabilityNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white60, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rakibin destesinde belirgin kategorik açık yok — dengeli oynuyor.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRec extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF12172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Center(
        child: Text(
          'Yeterli ranked maç verisi yok.',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
