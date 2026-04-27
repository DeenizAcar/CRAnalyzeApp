import '../data/models/deck.dart';
import '../data/static/win_conditions.dart';

/// Bir destenin ana win condition'ını bulur. Birden fazla win cond kart varsa
/// en yuksek elixir maliyetli olan seçilir (beatdown one cikar).
String? detectWinCondition(DeckModel deck) {
  final wcCards =
      deck.cards.where((c) => winConditionCardNames.contains(c.name)).toList();
  if (wcCards.isEmpty) return null;
  wcCards.sort((a, b) => b.elixirCost.compareTo(a.elixirCost));
  return wcCards.first.name;
}
