import '../data/models/deck.dart';

class DeckRecommendation {
  final DeckModel deck;
  final double score;
  final String reasoning;
  final Map<String, double> signalBreakdown;

  const DeckRecommendation({
    required this.deck,
    required this.score,
    required this.reasoning,
    this.signalBreakdown = const {},
  });
}

class OpponentProfile {
  final String tag;
  final String name;
  final List<DeckModel> recentDecks;
  final DeckModel? mostUsedDeck;
  final String? archetype;

  const OpponentProfile({
    required this.tag,
    required this.name,
    required this.recentDecks,
    this.mostUsedDeck,
    this.archetype,
  });
}

abstract class RecommendationEngine {
  Future<List<DeckRecommendation>> recommendAntiDecks(
    OpponentProfile opponent, {
    int maxResults = 100,
  });
}
