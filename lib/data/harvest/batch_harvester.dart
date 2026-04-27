import '../api/cr_api_client.dart';
import 'matchup_record.dart';
import 'matchup_store.dart';

/// Pro tag listesinden ranked maclari toplar, MatchupRecord'a cevirir,
/// MatchupStore'a yazar.
class BatchHarvester {
  final CRApiClient _api;
  final MatchupStore _store;
  final void Function(String)? _log;

  BatchHarvester({
    required CRApiClient api,
    required MatchupStore store,
    void Function(String message)? log,
  })  : _api = api,
        _store = store,
        _log = log;

  /// Bir tag listesi al, sonuç olarak: yeni eklenen kayit sayisi + total fetched battles.
  Future<HarvestResult> harvest({
    required List<String> playerTags,
    Set<String> includedBattleTypes = const {'pathOfLegend'},
    Duration delayBetweenRequests = const Duration(milliseconds: 250),
  }) async {
    var totalFetched = 0;
    var totalRanked = 0;
    final newRecords = <MatchupRecord>[];

    for (var i = 0; i < playerTags.length; i++) {
      final tag = playerTags[i];
      _log?.call('[$i/${playerTags.length}] $tag harvest...');
      try {
        final raw = await _api.getBattleLogRaw(tag);
        totalFetched += raw.length;
        for (final battle in raw) {
          final type = battle['type'] as String?;
          if (type == null || !includedBattleTypes.contains(type)) continue;
          final record = _toRecord(battle);
          if (record != null) {
            newRecords.add(record);
            totalRanked++;
          }
        }
      } catch (e) {
        _log?.call('  ! $tag hata: $e');
      }
      if (delayBetweenRequests > Duration.zero) {
        await Future.delayed(delayBetweenRequests);
      }
    }

    final added = _store.addAll(newRecords);
    return HarvestResult(
      totalPlayers: playerTags.length,
      totalBattlesFetched: totalFetched,
      totalRankedBattles: totalRanked,
      newRecordsAdded: added,
      totalStoreSize: _store.count,
    );
  }

  MatchupRecord? _toRecord(Map<String, dynamic> battle) {
    try {
      final team = (battle['team'] as List).first as Map<String, dynamic>;
      final opp = (battle['opponent'] as List).first as Map<String, dynamic>;
      final teamCrowns = team['crowns'] as int? ?? 0;
      final oppCrowns = opp['crowns'] as int? ?? 0;
      if (teamCrowns == oppCrowns) return null; // beraberlik
      final teamCards = _extractCardNames(team);
      final oppCards = _extractCardNames(opp);
      if (teamCards.length != 8 || oppCards.length != 8) return null;

      final teamWon = teamCrowns > oppCrowns;
      return MatchupRecord(
        winnerCards: (teamWon ? teamCards : oppCards)..sort(),
        loserCards: (teamWon ? oppCards : teamCards)..sort(),
        battleTime: _parseBattleTime(battle['battleTime'] as String),
        winnerTag: (teamWon ? team['tag'] : opp['tag']) as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  List<String> _extractCardNames(Map<String, dynamic> side) {
    final cards = (side['cards'] as List? ?? []).cast<Map<String, dynamic>>();
    return cards.map((c) => c['name'] as String? ?? '').where((s) => s.isNotEmpty).toList();
  }

  DateTime _parseBattleTime(String raw) {
    final iso =
        '${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 11)}:${raw.substring(11, 13)}:${raw.substring(13, 15)}Z';
    return DateTime.parse(iso);
  }
}

class HarvestResult {
  final int totalPlayers;
  final int totalBattlesFetched;
  final int totalRankedBattles;
  final int newRecordsAdded;
  final int totalStoreSize;

  const HarvestResult({
    required this.totalPlayers,
    required this.totalBattlesFetched,
    required this.totalRankedBattles,
    required this.newRecordsAdded,
    required this.totalStoreSize,
  });

  @override
  String toString() => '''
HarvestResult:
  Oyuncu sayisi   : $totalPlayers
  Cekilen mac     : $totalBattlesFetched
  Ranked mac      : $totalRankedBattles
  Yeni eklenen    : $newRecordsAdded
  Toplam DB       : $totalStoreSize
''';
}
