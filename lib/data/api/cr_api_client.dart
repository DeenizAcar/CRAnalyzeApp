import '../models/battle.dart';
import '../models/player.dart';

abstract class CRApiClient {
  Future<PlayerModel> getPlayer(String playerTag);

  Future<List<BattleModel>> getBattleLog(String playerTag);

  /// Ham battlelog JSON'u — cache için kullanılır (yeni alan gelirse kaybetmemek).
  Future<List<Map<String, dynamic>>> getBattleLogRaw(String playerTag);

  /// Tum kart katalogunu cek (~120 kart, name + iconUrls).
  Future<List<Map<String, dynamic>>> getCardsRaw();

  /// Bir bolgenin Path of Legends top oyuncu siralamasi.
  /// locationId 'global' icin global, '57000239' Turkey vb.
  Future<List<Map<String, dynamic>>> getPathOfLegendsRanking(
    String locationId, {
    int limit = 50,
  });

  Future<void> dispose();
}

class CRApiException implements Exception {
  final int? statusCode;
  final String message;
  const CRApiException(this.message, {this.statusCode});

  @override
  String toString() => 'CRApiException($statusCode): $message';
}
