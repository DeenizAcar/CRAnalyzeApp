import '../data/models/deck.dart';
import '../data/static/meta_decks.dart';

class DeckRecommendation {
  /// Statik aday deste (kart adlari).
  final MetaDeck deck;

  /// 0-1 arasi skor (1 = mukemmel anti-deck).
  final double score;

  /// Insanlar icin aciklama (neden bu deste oneriliyor).
  final String reasoning;

  /// Skoru olusturan sinyaller (debug + ileride detayli ekran icin).
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

/// Rakip destelerinden birine karşı anti-deck onerisi uretir.
abstract class RecommendationEngine {
  /// Tek bir rakip destesi icin onerileri uret (en yuksek skordan dusuge).
  List<DeckRecommendation> recommendForDeck(
    DeckModel opponentDeck, {
    int maxResults = 5,
  });
}
