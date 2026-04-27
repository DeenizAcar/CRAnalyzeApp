import 'card.dart';
import 'deck.dart';

class PlayerModel {
  final String tag;
  final String name;
  final int trophies;
  final int? bestTrophies;
  final DeckModel? currentDeck;
  final List<CardModel> cardCollection;

  const PlayerModel({
    required this.tag,
    required this.name,
    required this.trophies,
    this.bestTrophies,
    this.currentDeck,
    this.cardCollection = const [],
  });
}
