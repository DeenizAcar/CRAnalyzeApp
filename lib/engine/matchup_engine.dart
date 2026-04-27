import '../data/models/deck.dart';
import '../data/static/meta_decks.dart';
import 'matchup_scorer.dart';
import 'recommendation_engine.dart';

/// Matchup veritabanı kullanan yapay zeka motoru. RuleBasedEngine'in yerine
/// gecer; daha "gerçekçi" çünkü skorlar pro mac verisinden çıkar.
class MatchupEngine implements RecommendationEngine {
  final List<MetaDeck> _pool;
  final MatchupScorer _scorer;

  MatchupEngine({
    required List<MetaDeck> pool,
    required MatchupScorer scorer,
  })  : _pool = pool,
        _scorer = scorer;

  @override
  List<DeckRecommendation> recommendForDeck(
    DeckModel opponentDeck,
    {int maxResults = 5}
  ) {
    final opponentCards = opponentDeck.cards.map((c) => c.name).toList();

    final scored = _pool.map((candidate) {
      final result = _scorer.scoreCandidateVsOpponent(
        candidateCards: candidate.cardNames,
        opponentCards: opponentCards,
      );
      final reasoning = result.samples == 0
          ? 'Pro mac verisinde benzer matchup yok'
          : 'Pro mac: ${result.samples} ornek, %${(result.winRate * 100).round()} win rate';
      return DeckRecommendation(
        deck: candidate,
        score: result.score,
        reasoning: reasoning,
        signalBreakdown: {
          'samples': result.samples.toDouble(),
          'wins': result.wins.toDouble(),
          'losses': result.losses.toDouble(),
        },
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxResults).toList();
  }

  /// Birden fazla rakip destesine karsi tek bir 'genel anti-deck' oner.
  /// Her aday icin: rakibin destelerine karsi kullanim agirlikli ortalama skor.
  /// Skor: sum(score_i * weight_i) / sum(weight_i)
  /// weight_i = rakibin destesini kullanma sayisi (count).
  List<DeckRecommendation> recommendCombined({
    required List<({DeckModel deck, int weight})> opponentDecks,
    int maxResults = 5,
  }) {
    if (opponentDecks.isEmpty) return const [];

    final scored = _pool.map((candidate) {
      var weightedScoreSum = 0.0;
      var weightSum = 0;
      var totalSamples = 0;
      var totalWins = 0;
      var coveredDeckCount = 0;
      for (final entry in opponentDecks) {
        final result = _scorer.scoreCandidateVsOpponent(
          candidateCards: candidate.cardNames,
          opponentCards: entry.deck.cards.map((c) => c.name).toList(),
        );
        weightedScoreSum += result.score * entry.weight;
        weightSum += entry.weight;
        totalSamples += result.samples;
        totalWins += result.wins;
        if (result.samples > 0) coveredDeckCount++;
      }
      final score = weightSum == 0 ? 0.0 : weightedScoreSum / weightSum;
      final reasoning = totalSamples == 0
          ? 'Pro mac verisinde tum destelere karsi ornek yok'
          : '$coveredDeckCount/${opponentDecks.length} destede veri var, '
              'toplam $totalSamples pro ornek, %${totalSamples == 0 ? 0 : (totalWins * 100 / totalSamples).round()} ortalama win rate';
      return DeckRecommendation(
        deck: candidate,
        score: score,
        reasoning: reasoning,
        signalBreakdown: {
          'samples': totalSamples.toDouble(),
          'wins': totalWins.toDouble(),
          'covered_decks': coveredDeckCount.toDouble(),
        },
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxResults).toList();
  }
}
