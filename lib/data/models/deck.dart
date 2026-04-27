import 'card.dart';

class DeckModel {
  final List<CardModel> cards;
  final double averageElixir;
  final String? archetype;

  const DeckModel({
    required this.cards,
    required this.averageElixir,
    this.archetype,
  });

  factory DeckModel.fromCards(List<CardModel> cards) {
    final avg = cards.isEmpty
        ? 0.0
        : cards.map((c) => c.elixirCost).reduce((a, b) => a + b) / cards.length;
    return DeckModel(cards: cards, averageElixir: avg);
  }

  String get fingerprint {
    final ids = cards.map((c) => c.id).toList()..sort();
    return ids.join('-');
  }
}
