import 'package:flutter/material.dart';

import '../../data/card_catalog.dart';
import '../../data/static/meta_decks.dart';
import '../../engine/recommendation_engine.dart';

class AntiDeckBlock extends StatelessWidget {
  final List<DeckRecommendation> recommendations;
  final String? winCondition;
  final bool showHeader;

  const AntiDeckBlock({
    super.key,
    required this.recommendations,
    this.winCondition,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2138),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF40C4FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                const Icon(Icons.gps_fixed, size: 20, color: Color(0xFF40C4FF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    winCondition != null
                        ? 'Bunu yenmek için (win cond: $winCondition)'
                        : 'Bunu yenmek için',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF40C4FF),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (recommendations.isEmpty)
            Text(
              'Uygun anti-deck önerisi bulunamadı.',
              style: theme.textTheme.bodySmall,
            )
          else
            ...recommendations.map((r) => _RecCard(rec: r)),
        ],
      ),
    );
  }
}

class _RecCard extends StatelessWidget {
  final DeckRecommendation rec;
  const _RecCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scorePct = (rec.score * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1729),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rec.deck.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _scoreColor(scorePct).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _scoreColor(scorePct),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'uyum %$scorePct',
                  style: TextStyle(
                    color: _scoreColor(scorePct),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            rec.reasoning,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: rec.deck.slottedCards
                .map((slot) => _MiniCardTile(slot: slot))
                .toList(),
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

class _MiniCardTile extends StatelessWidget {
  final MetaCardSlot slot;
  static const double _width = 44;
  static const double _height = 56;

  const _MiniCardTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconUrl = _resolveIcon();
    final borderColor = slot.isEvolution
        ? Colors.amber
        : slot.isHero
            ? Colors.orange
            : theme.colorScheme.outline.withValues(alpha: 0.3);
    final borderWidth = slot.isEvolution || slot.isHero ? 1.5 : 0.5;

    return SizedBox(
      width: _width,
      height: _height,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: iconUrl != null
                  ? Image.network(
                      iconUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) => _miniPlaceholder(theme),
                    )
                  : _miniPlaceholder(theme),
            ),
            if (slot.isEvolution)
              const Positioned(
                top: 1,
                right: 1,
                child: Icon(Icons.auto_awesome, size: 10, color: Colors.amber),
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

  Widget _miniPlaceholder(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          slot.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 8),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
