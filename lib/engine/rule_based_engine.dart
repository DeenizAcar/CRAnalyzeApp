import '../data/models/deck.dart';
import '../data/static/counters.dart';
import '../data/static/meta_decks.dart';
import 'recommendation_engine.dart';
import 'win_condition.dart';

class RuleBasedEngine implements RecommendationEngine {
  final List<MetaDeck> _pool;

  RuleBasedEngine({List<MetaDeck>? pool}) : _pool = pool ?? metaDecks;

  /// Bir aday destenin (anti-deck) tek bir rakip destesine karşı skoru.
  /// Sinyaller:
  /// - Counter score: aday destedeki kartlar, rakibin win cond'ını
  ///   ne kadar iyi counter'lıyor (counters.dart'tan).
  /// - Elixir uyumu: rakibin elixir maliyetine gore basit ayarlama.
  ///   Cycle (avg <3.5) icin ayni cycle’lı desteler hafif boost,
  ///   beatdown (avg >=4) icin control/inferno desteler boost.
  ({double score, String reasoning, Map<String, double> signals}) _scoreCandidate(
    MetaDeck candidate,
    DeckModel opponentDeck,
    String? winCondition,
  ) {
    final signals = <String, double>{};
    final reasons = <String>[];

    // 1. Counter sinyali (en onemli)
    var counterScore = 0.0;
    final wcCounters = winCondition == null ? null : counters[winCondition];
    if (wcCounters != null) {
      var matchedCounters = 0;
      for (final cardName in candidate.cardNames) {
        final c = wcCounters[cardName];
        if (c != null) {
          counterScore += c;
          matchedCounters++;
        }
      }
      // En guclu counter'lar zaten 1.0; toplam birden fazla varsa zaten yuksek
      // olur. 0-1 araligina sikalim: max 3 counter agirlikli sayilsin.
      counterScore = (counterScore / 3.0).clamp(0.0, 1.0);
      if (matchedCounters > 0) {
        reasons.add('$winCondition icin $matchedCounters counter kart');
      }
    }
    signals['counter'] = counterScore;

    // 2. Elixir/archetype uyumu (ikincil)
    var archetypeScore = 0.5; // notr
    final oppAvg = opponentDeck.averageElixir;
    if (oppAvg < 3.5) {
      // Rakip cycle: ayni hizda counter cycle iyi calisir
      if (candidate.archetype == 'cycle' || candidate.archetype == 'siege') {
        archetypeScore = 0.8;
        reasons.add('Rakip cycle: ${candidate.archetype} arketip uyumu');
      }
    } else if (oppAvg >= 4.2) {
      // Rakip beatdown: control/cycle ile elixir avantaji aranir
      if (candidate.archetype == 'cycle' || candidate.archetype == 'control') {
        archetypeScore = 0.75;
        reasons.add('Rakip agir: ${candidate.archetype} ile elixir avantaji');
      }
    }
    signals['archetype'] = archetypeScore;

    // Birlestir: counter %70, archetype %30
    final score = counterScore * 0.7 + archetypeScore * 0.3;
    final reasoning = reasons.isEmpty
        ? 'Genel meta uyumu'
        : reasons.join(' + ');
    return (score: score, reasoning: reasoning, signals: signals);
  }

  @override
  List<DeckRecommendation> recommendForDeck(
    DeckModel opponentDeck, {
    int maxResults = 5,
  }) {
    final winCond = detectWinCondition(opponentDeck);

    final scored = _pool.map((candidate) {
      final r = _scoreCandidate(candidate, opponentDeck, winCond);
      return DeckRecommendation(
        deck: candidate,
        score: r.score,
        reasoning: r.reasoning,
        signalBreakdown: r.signals,
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxResults).toList();
  }
}
