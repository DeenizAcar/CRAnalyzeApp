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
}
