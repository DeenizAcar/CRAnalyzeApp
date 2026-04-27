import 'package:flutter/material.dart';

import '../../data/card_catalog.dart';
import '../../data/models/card.dart';
import '../../data/models/deck.dart';

class DeckCardWidget extends StatelessWidget {
  final DeckModel deck;
  final String? title;
  final String? subtitle;
  final Color? accent;

  const DeckCardWidget({
    super.key,
    required this.deck,
    this.title,
    this.subtitle,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2138),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB388FF),
                fontSize: 15,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: deck.cards.map((c) => CardTile(card: c)).toList(),
          ),
        ],
      ),
    );
  }
}

class CardTile extends StatelessWidget {
  final CardModel card;
  static const double _width = 84;
  static const double _height = 108;

  const CardTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconUrl = card.displayIconUrl ??
        (card.isChampion ? CardCatalog.heroIconFor(card.name) : null);
    final rarityColor = _rarityColor(card.rarity);

    return SizedBox(
      width: _width,
      height: _height,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: card.isEvolution
                ? Colors.amber
                : rarityColor.withValues(alpha: 0.5),
            width: card.isEvolution ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
            children: [
              Positioned.fill(
                child: iconUrl != null
                    ? Image.network(
                        iconUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, error, stack) => _Placeholder(card: card),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                    : _Placeholder(card: card),
              ),
              if (card.isEvolution)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(Icons.auto_awesome, size: 12, color: Colors.amber),
                ),
            ],
          ),
        ),
      );
  }

  static Color _rarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.cyan;
      case 'champion':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }
}

class _Placeholder extends StatelessWidget {
  final CardModel card;
  const _Placeholder({required this.card});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          card.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
