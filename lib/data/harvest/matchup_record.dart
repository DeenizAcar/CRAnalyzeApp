/// Tek bir matchup gozlem: hangi deste hangi rakibe karsi kazandi/kaybetti.
/// Pro maclardan toplanir, statik bir veri kaydıdır.
class MatchupRecord {
  /// Kazanan oyuncunun destesi (8 kart adi, alfabetik).
  final List<String> winnerCards;

  /// Kaybeden oyuncunun destesi (8 kart adi, alfabetik).
  final List<String> loserCards;

  /// Mac zamani (en yeni kayitlari one cikarmak icin).
  final DateTime battleTime;

  /// Pro tag'i (data kalitesi takibi).
  final String winnerTag;

  const MatchupRecord({
    required this.winnerCards,
    required this.loserCards,
    required this.battleTime,
    required this.winnerTag,
  });

  /// JSON dosyasi icin (zaman + tag + 16 kart hash'i sayilebilir).
  String get id =>
      '${battleTime.toUtc().toIso8601String()}|$winnerTag|${winnerCards.join(",")}|${loserCards.join(",")}';

  Map<String, dynamic> toJson() => {
        'winnerCards': winnerCards,
        'loserCards': loserCards,
        'battleTime': battleTime.toUtc().toIso8601String(),
        'winnerTag': winnerTag,
      };

  factory MatchupRecord.fromJson(Map<String, dynamic> j) => MatchupRecord(
        winnerCards: (j['winnerCards'] as List).cast<String>(),
        loserCards: (j['loserCards'] as List).cast<String>(),
        battleTime: DateTime.parse(j['battleTime'] as String),
        winnerTag: j['winnerTag'] as String,
      );
}
