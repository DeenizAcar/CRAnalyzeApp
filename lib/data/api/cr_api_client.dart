import '../models/battle.dart';
import '../models/player.dart';

abstract class CRApiClient {
  Future<PlayerModel> getPlayer(String playerTag);

  Future<List<BattleModel>> getBattleLog(String playerTag);

  Future<void> dispose();
}

class CRApiException implements Exception {
  final int? statusCode;
  final String message;
  const CRApiException(this.message, {this.statusCode});

  @override
  String toString() => 'CRApiException($statusCode): $message';
}
