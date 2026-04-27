import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/battle.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/player.dart';
import 'cr_api_client.dart';

class SupercellApiClient implements CRApiClient {
  static const String _baseUrl = 'https://api.clashroyale.com/v1';

  final String _token;
  final http.Client _http;

  SupercellApiClient({required String token, http.Client? httpClient})
      : _token = token,
        _http = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      };

  String _encodeTag(String tag) {
    final clean = tag.startsWith('#') ? tag : '#$tag';
    return Uri.encodeComponent(clean);
  }

  @override
  Future<PlayerModel> getPlayer(String playerTag) async {
    final url = Uri.parse('$_baseUrl/players/${_encodeTag(playerTag)}');
    final res = await _http.get(url, headers: _headers);
    if (res.statusCode != 200) {
      throw CRApiException(res.body, statusCode: res.statusCode);
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;

    final cards = (json['cards'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CardModel.fromApiJson)
        .toList();

    final currentDeck = (json['currentDeck'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CardModel.fromApiJson)
        .toList();

    return PlayerModel(
      tag: json['tag'] as String,
      name: json['name'] as String? ?? '',
      trophies: json['trophies'] as int? ?? 0,
      bestTrophies: json['bestTrophies'] as int?,
      cardCollection: cards,
      currentDeck: currentDeck.isEmpty ? null : DeckModel.fromCards(currentDeck),
    );
  }

  @override
  Future<List<BattleModel>> getBattleLog(String playerTag) async {
    final url = Uri.parse('$_baseUrl/players/${_encodeTag(playerTag)}/battlelog');
    final res = await _http.get(url, headers: _headers);
    if (res.statusCode != 200) {
      throw CRApiException(res.body, statusCode: res.statusCode);
    }
    final list = jsonDecode(res.body) as List;
    return list.cast<Map<String, dynamic>>().map(_parseBattle).toList();
  }

  BattleModel _parseBattle(Map<String, dynamic> json) {
    final team = (json['team'] as List).first as Map<String, dynamic>;
    final opponent = (json['opponent'] as List).first as Map<String, dynamic>;

    final teamCards = (team['cards'] as List)
        .cast<Map<String, dynamic>>()
        .map(CardModel.fromApiJson)
        .toList();
    final oppCards = (opponent['cards'] as List)
        .cast<Map<String, dynamic>>()
        .map(CardModel.fromApiJson)
        .toList();

    return BattleModel(
      battleTime: _parseBattleTime(json['battleTime'] as String),
      type: json['type'] as String? ?? 'unknown',
      playerTag: team['tag'] as String? ?? '',
      opponentTag: opponent['tag'] as String? ?? '',
      playerDeck: DeckModel.fromCards(teamCards),
      opponentDeck: DeckModel.fromCards(oppCards),
      playerCrowns: team['crowns'] as int? ?? 0,
      opponentCrowns: opponent['crowns'] as int? ?? 0,
    );
  }

  DateTime _parseBattleTime(String raw) {
    final iso =
        '${raw.substring(0, 4)}-${raw.substring(4, 6)}-${raw.substring(6, 11)}:${raw.substring(11, 13)}:${raw.substring(13, 15)}Z';
    return DateTime.parse(iso);
  }

  @override
  Future<void> dispose() async {
    _http.close();
  }
}
