import 'deck.dart';

class BattleModel {
  final DateTime battleTime;
  final String type;
  final String playerTag;
  final String opponentTag;
  final DeckModel playerDeck;
  final DeckModel opponentDeck;
  final int playerCrowns;
  final int opponentCrowns;

  const BattleModel({
    required this.battleTime,
    required this.type,
    required this.playerTag,
    required this.opponentTag,
    required this.playerDeck,
    required this.opponentDeck,
    required this.playerCrowns,
    required this.opponentCrowns,
  });

  bool get playerWon => playerCrowns > opponentCrowns;

  /// İki maç eş benzerse aynı, dedupe için. battleTime + opponentTag yeterince
  /// ayırt edici (aynı oyuncu aynı saniyede iki ayrı rakibe karşı oynayamaz).
  String get id =>
      '${battleTime.toUtc().toIso8601String()}|$playerTag|$opponentTag';
}
