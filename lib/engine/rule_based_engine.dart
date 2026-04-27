import 'recommendation_engine.dart';

class RuleBasedEngine implements RecommendationEngine {
  @override
  Future<List<DeckRecommendation>> recommendAntiDecks(
    OpponentProfile opponent, {
    int maxResults = 100,
  }) async {
    return const [];
  }
}
