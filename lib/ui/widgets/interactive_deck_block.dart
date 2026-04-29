import 'package:flutter/material.dart';

import '../../data/card_catalog.dart';
import '../../data/models/card.dart';
import '../../data/models/deck.dart';
import '../../data/static/card_categories.dart';

/// Bir rakip destesi icin: kartlara tiklanir -> 'oynandi' isareti.
/// Altinda 'Kalan tehditler' kutusu (oynanmamis spell + win cond).
///
/// State: oynanan kart setini tutar (sadece bu widget kapsaminda, sayfa
/// degisince sifirlanir — bu UX kasitli, yeni mac yeni durum).
class InteractiveDeckBlock extends StatefulWidget {
  final DeckModel deck;
  final String title;

  const InteractiveDeckBlock({
    super.key,
    required this.deck,
    required this.title,
  });

  @override
  State<InteractiveDeckBlock> createState() => _InteractiveDeckBlockState();
}

class _InteractiveDeckBlockState extends State<InteractiveDeckBlock> {
  final Set<int> _playedCardIds = {};

  void _toggle(CardModel card) {
    setState(() {
      if (_playedCardIds.contains(card.id)) {
        _playedCardIds.remove(card.id);
      } else {
        _playedCardIds.add(card.id);
      }
    });
  }

  bool _isPlayed(CardModel c) => _playedCardIds.contains(c.id);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final spells = widget.deck.cards
        .where((c) => cardCategories[c.name]?.contains(CardCategory.spell) ?? false)
        .toList();
    final winConditions = widget.deck.cards
        .where(
            (c) => cardCategories[c.name]?.contains(CardCategory.winCondition) ?? false)
        .toList();

    final remainingSpells = spells.where((c) => !_isPlayed(c)).toList();
    final remainingWcs = winConditions.where((c) => !_isPlayed(c)).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_playedCardIds.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => setState(_playedCardIds.clear),
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Sıfırla'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 28),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Maç sırasında rakibin oynadığı kartlara tıkla — kalan tehditler aşağıda görünür.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.deck.cards
                  .map((c) => _ToggleableCard(
                        card: c,
                        played: _isPlayed(c),
                        onTap: () => _toggle(c),
                      ))
                  .toList(),
            ),
            if (_playedCardIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              _RemainingThreats(
                remainingSpells: remainingSpells,
                remainingWinConditions: remainingWcs,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleableCard extends StatelessWidget {
  final CardModel card;
  final bool played;
  final VoidCallback onTap;
  static const double _w = 70;
  static const double _h = 88;

  const _ToggleableCard({
    required this.card,
    required this.played,
    required this.onTap,
  });

  String? _resolveIcon() {
    if (card.isEvolution) {
      return CardCatalog.evolutionIconFor(card.name) ??
          CardCatalog.iconFor(card.name);
    }
    if (card.isChampion) {
      return CardCatalog.heroIconFor(card.name) ?? CardCatalog.iconFor(card.name);
    }
    return CardCatalog.iconFor(card.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = _resolveIcon() ?? card.displayIconUrl;
    final borderColor = card.isEvolution
        ? const Color(0xFFFFC107)
        : card.isChampion
            ? const Color(0xFFFF8A50)
            : Colors.white24;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: _w,
        height: _h,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: card.isEvolution || card.isChampion ? 2 : 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: ColorFiltered(
                colorFilter: played
                    ? const ColorFilter.matrix(<double>[
                        0.3, 0.3, 0.3, 0, 0,
                        0.3, 0.3, 0.3, 0, 0,
                        0.3, 0.3, 0.3, 0, 0,
                        0,   0,   0,   1, 0,
                      ])
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: url != null
                    ? Image.network(url, fit: BoxFit.contain)
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            card.name,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ),
            ),
            if (played)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, size: 18, color: Colors.greenAccent),
                ),
              ),
            if (card.isEvolution && !played)
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(Icons.auto_awesome, size: 12, color: Color(0xFFFFC107)),
              ),
          ],
        ),
      ),
    );
  }
}

class _RemainingThreats extends StatelessWidget {
  final List<CardModel> remainingSpells;
  final List<CardModel> remainingWinConditions;

  const _RemainingThreats({
    required this.remainingSpells,
    required this.remainingWinConditions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF12172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF40C4FF).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, size: 16, color: Color(0xFF40C4FF)),
              const SizedBox(width: 6),
              Text(
                'Kalan tehditler',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF40C4FF),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ThreatRow(
            label: 'Büyüler',
            cards: remainingSpells,
            emptyText: 'Tüm büyüler oynandı.',
            badgeColor: const Color(0xFFB388FF),
          ),
          const SizedBox(height: 6),
          _ThreatRow(
            label: 'Win condition',
            cards: remainingWinConditions,
            emptyText: 'Win condition oynandı, baskı azalır.',
            badgeColor: const Color(0xFFFF8A50),
          ),
        ],
      ),
    );
  }
}

class _ThreatRow extends StatelessWidget {
  final String label;
  final List<CardModel> cards;
  final String emptyText;
  final Color badgeColor;

  const _ThreatRow({
    required this.label,
    required this.cards,
    required this.emptyText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: badgeColor, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: badgeColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: cards.isEmpty
              ? Text(
                  emptyText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.greenAccent.shade100,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: cards.map((c) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
