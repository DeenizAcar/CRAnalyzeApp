import '../data/api/cr_api_client.dart';
import '../data/api/supercell_api_client.dart';
import '../data/cache/battle_cache.dart';
import '../data/models/battle.dart';
import '../data/models/deck.dart';
import 'recommendation_engine.dart';

class DeckUsage {
  final DeckModel deck;
  int count;
  int wins;

  DeckUsage(this.deck, {this.count = 0, this.wins = 0});

  double get winRate => count == 0 ? 0 : wins / count;
}

class OpponentAnalysis {
  final OpponentProfile profile;
  final List<DeckUsage> deckUsages;
  final List<BattleModel> battles;
  final int rawBattleCount;
  final int newlyAddedCount;
  final DateTime? lastUpdated;

  const OpponentAnalysis({
    required this.profile,
    required this.deckUsages,
    required this.battles,
    required this.rawBattleCount,
    required this.newlyAddedCount,
    required this.lastUpdated,
  });

  int get totalBattles => battles.length;
  int get filteredOutCount => rawBattleCount - totalBattles;
  int get wins => battles.where((b) => b.playerWon).length;
  int get losses => totalBattles - wins;
  double get winRate => totalBattles == 0 ? 0 : wins / totalBattles;
}

/// Anti-deck analizinde anlamlı olan maç tipleri.
/// Sadece oyuncunun kendi destesini seçtiği rekabetçi modlar.
const Set<String> rankedBattleTypes = {
  'pathOfLegend',
};

class OpponentAnalyzer {
  final CRApiClient _api;
  final BattleCache _cache;
  final Set<String> includedBattleTypes;

  OpponentAnalyzer(
    this._api, {
    required BattleCache cache,
    Set<String>? includedBattleTypes,
  })  : _cache = cache,
        includedBattleTypes = includedBattleTypes ?? rankedBattleTypes;

  Future<OpponentAnalysis> analyze(String playerTag) async {
    final player = await _api.getPlayer(playerTag);

    // 1. Cache'i oku
    // 2. API'den son 30'u cek
    // 3. Cache'e merge et (yeni olanlar eklensin)
    // 4. Cache'in tamami uzerinden analiz yap
    final fresh = await _api.getBattleLogRaw(playerTag);
    final newlyAdded = await _cache.merge(playerTag, fresh);
    final allRaw = await _cache.read(playerTag);
    final lastUpdated = await _cache.lastUpdated(playerTag);

    final allBattles =
        allRaw.map(SupercellApiClient.parseBattle).toList(growable: false);
    final battles =
        allBattles.where((b) => includedBattleTypes.contains(b.type)).toList();

    final usage = <String, DeckUsage>{};
    for (final b in battles) {
      final deck = b.playerDeck;
      final fp = deck.fingerprint;
      final entry = usage.putIfAbsent(fp, () => DeckUsage(deck));
      entry.count++;
      if (b.playerWon) entry.wins++;
    }

    final ranked = usage.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final recentDecks = ranked.map((u) => u.deck).toList();

    final profile = OpponentProfile(
      tag: player.tag,
      name: player.name,
      recentDecks: recentDecks,
      mostUsedDeck: recentDecks.isEmpty ? null : recentDecks.first,
    );

    return OpponentAnalysis(
      profile: profile,
      deckUsages: ranked,
      battles: battles,
      rawBattleCount: allBattles.length,
      newlyAddedCount: newlyAdded,
      lastUpdated: lastUpdated,
    );
  }
}
