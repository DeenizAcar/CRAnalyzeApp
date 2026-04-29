import 'package:flutter/material.dart';

import '../../data/card_catalog.dart';
import '../../data/static/card_categories.dart';

/// CRL düello modu: rakibin açtığı kartlar + bunlardan çıkardığımız taktik notlar.
class PlayedCardsSummary extends StatelessWidget {
  final Set<String> playedCards;

  const PlayedCardsSummary({super.key, required this.playedCards});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (playedCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF12172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Icon(Icons.touch_app, size: 16, color: Colors.white60),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Maç sırasında rakibin oynadığı kartları aşağıdaki listeden işaretle. Çıkarımlar burada gözükecek.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
              ),
            ),
          ],
        ),
      );
    }

    final notes = _generateNotes();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2D3D), Color(0xFF12172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF40C4FF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, size: 22, color: Color(0xFF40C4FF)),
              const SizedBox(width: 8),
              Text(
                'Açılan ${playedCards.length} kart',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF40C4FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: playedCards.map((n) => _MiniIcon(name: n)).toList(),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 10),
            Text(
              'CRL kuralı: bu kartlar diğer destelerinde olamaz.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.white60, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            ...notes.map((n) => _NoteRow(note: n)),
          ],
        ],
      ),
    );
  }

  List<_TacticalNote> _generateNotes() {
    final notes = <_TacticalNote>[];

    // Hangi kategorilerdeki BUYUK kartlar acildi?
    final played = playedCards;

    // Buyuk spell'ler: Fireball, Rocket, Lightning, Poison, Earthquake, Freeze
    const bigSpells = {
      'Fireball', 'Rocket', 'Lightning', 'Poison', 'Earthquake', 'Freeze'
    };
    final playedBigSpells = played.intersection(bigSpells);
    if (playedBigSpells.length >= 2) {
      notes.add(_TacticalNote(
        icon: Icons.bolt,
        color: const Color(0xFFB388FF),
        title: 'Büyük büyüleri tükendi (${playedBigSpells.join(", ")})',
        body: 'Diğer 3 destesinde büyük spell yok → cluster swarm güvenli '
            '(Şok Birliği, Buz Büyücüsü, Witch, Yığın, Goblin Gang)',
      ));
    } else if (playedBigSpells.length == 1) {
      notes.add(_TacticalNote(
        icon: Icons.warning_amber,
        color: const Color(0xFFFFB300),
        title: '${playedBigSpells.first} oynandı',
        body: 'Bu spell diğer destelerde yok → cluster oynanabilir, ama '
            'rakipte hala 1 büyük spell ihtimali var',
      ));
    }

    // Win condition acildi mi?
    final playedWcs = played.where(
      (n) => cardCategories[n]?.contains(CardCategory.winCondition) ?? false,
    ).toList();
    if (playedWcs.isNotEmpty) {
      notes.add(_TacticalNote(
        icon: Icons.flag,
        color: const Color(0xFFFF8A50),
        title: 'Win condition: ${playedWcs.join(", ")}',
        body: 'Bu win cond rakibin diğer destelerinde olamaz → ona karşı counter '
            'sonraki maçlarda gerekmez',
      ));
    }

    // Buyuk tanklar acildi mi?
    const bigTanks = {
      'Golem', 'Lava Hound', 'Electro Giant', 'P.E.K.K.A',
      'Royal Giant', 'Mega Knight', 'Goblin Giant', 'Giant'
    };
    final playedTanks = played.intersection(bigTanks);
    if (playedTanks.isNotEmpty) {
      notes.add(_TacticalNote(
        icon: Icons.shield,
        color: const Color(0xFFE57373),
        title: 'Ağır tank: ${playedTanks.join(", ")}',
        body: 'Diğer destelerinde olamaz → tank counter (Inferno Tower, '
            'Mini P.E.K.K.A) sonraki maçlarda lazım değil',
      ));
    }

    // Hava win cond
    const airWcs = {'Lava Hound', 'Balloon'};
    final playedAir = played.intersection(airWcs);
    if (playedAir.isNotEmpty) {
      notes.add(_TacticalNote(
        icon: Icons.cloud,
        color: const Color(0xFF80CBC4),
        title: 'Hava saldırısı: ${playedAir.join(", ")}',
        body: 'Hava counter (Musketeer, Inferno Dragon) diğer destelerde gereksiz',
      ));
    }

    return notes;
  }
}

class _TacticalNote {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _TacticalNote({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

class _NoteRow extends StatelessWidget {
  final _TacticalNote note;
  const _NoteRow({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(note.icon, color: note.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: note.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final String name;
  const _MiniIcon({required this.name});

  @override
  Widget build(BuildContext context) {
    final url = CardCatalog.iconFor(name);
    return SizedBox(
      width: 32,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF40C4FF), width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: url != null
            ? Image.network(url, fit: BoxFit.contain)
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 7),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
      ),
    );
  }
}
