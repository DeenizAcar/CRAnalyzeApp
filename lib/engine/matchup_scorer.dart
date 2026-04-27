import '../data/harvest/matchup_record.dart';

/// Matchup veritabanı kullanarak aday desteyi rakibe göre skorlar.
///
/// Sezgi: pro maçlarda "rakibe benzer destelere karşı" bizim "aday destemize
/// benzer desteler" kaç kez kazandı? Çok kazandıysa skor yüksek.
class MatchupScorer {
  final List<MatchupRecord> _records;

  /// Bir maçı dahil etmek için minimum benzerlik (kart örtüşme orani).
  /// 8 karttan kaç tane ortak olmali.
  final int minOverlap;

  MatchupScorer(this._records, {this.minOverlap = 5});

  /// Aday destenin rakip desteye karşı skoru (0-1).
  /// Kayıt sayısı dusukse skor düsuk olur (guven).
  ScoreResult scoreCandidateVsOpponent({
    required List<String> candidateCards,
    required List<String> opponentCards,
  }) {
    final candidateSet = candidateCards.toSet();
    final opponentSet = opponentCards.toSet();

    var winSamples = 0; // benzer rakip desteler — bizim adayimizin kazand. ornek
    var lossSamples = 0; // benzer rakip desteler — bizim adayimizin kaybett. ornek

    for (final r in _records) {
      // Senaryo 1: rakip kaybetmis (loserCards ~ opponent), kazanan ~ candidate?
      final loserOverlap = _overlap(r.loserCards.toSet(), opponentSet);
      if (loserOverlap >= minOverlap) {
        final winnerOverlap = _overlap(r.winnerCards.toSet(), candidateSet);
        if (winnerOverlap >= minOverlap) winSamples++;
      }
      // Senaryo 2: rakip kazanmis (winnerCards ~ opponent), kaybeden ~ candidate?
      final winnerOverlap = _overlap(r.winnerCards.toSet(), opponentSet);
      if (winnerOverlap >= minOverlap) {
        final loserOverlap = _overlap(r.loserCards.toSet(), candidateSet);
        if (loserOverlap >= minOverlap) lossSamples++;
      }
    }

    final totalSamples = winSamples + lossSamples;
    if (totalSamples == 0) {
      return ScoreResult(score: 0, samples: 0, wins: 0, losses: 0);
    }
    final winRate = winSamples / totalSamples;
    // Guven faktoru: 10+ ornek = 1.0, daha azinda azaltir
    final confidence = (totalSamples / 10.0).clamp(0.0, 1.0);
    // Final skor: win rate * confidence (orneklem azsa skor iniyor)
    final score = winRate * (0.5 + 0.5 * confidence);
    return ScoreResult(
      score: score,
      samples: totalSamples,
      wins: winSamples,
      losses: lossSamples,
    );
  }

  int _overlap(Set<String> a, Set<String> b) {
    var c = 0;
    for (final x in a) {
      if (b.contains(x)) c++;
    }
    return c;
  }
}

class ScoreResult {
  final double score;
  final int samples;
  final int wins;
  final int losses;

  const ScoreResult({
    required this.score,
    required this.samples,
    required this.wins,
    required this.losses,
  });

  double get winRate => samples == 0 ? 0 : wins / samples;
}
