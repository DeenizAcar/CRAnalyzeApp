import '../static/meta_decks.dart';

Map<String, dynamic> metaDeckToJson(MetaDeck d) => {
      'name': d.name,
      'archetype': d.archetype,
      'cards': d.cards
          .map((c) => {'name': c.name, 'variant': c.variant.name})
          .toList(),
    };

MetaDeck metaDeckFromJson(Map<String, dynamic> j) {
  // Eski format ile geriye doneuk uyum: 'cardNames' varsa normal kart say
  if (j['cards'] is List) {
    final list = (j['cards'] as List).cast<Map<String, dynamic>>();
    return MetaDeck(
      name: j['name'] as String,
      archetype: j['archetype'] as String,
      cards: list.map((c) {
        final v = c['variant'] as String? ?? 'normal';
        return MetaCardSlot(
          c['name'] as String,
          CardVariant.values.firstWhere(
            (x) => x.name == v,
            orElse: () => CardVariant.normal,
          ),
        );
      }).toList(),
    );
  }
  // Eski cache: cardNames stringleri
  final names = (j['cardNames'] as List).cast<String>();
  return MetaDeck(
    name: j['name'] as String,
    archetype: j['archetype'] as String,
    cards: names.map((n) => MetaCardSlot(n)).toList(),
  );
}
