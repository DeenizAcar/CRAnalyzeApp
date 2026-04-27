class CardModel {
  final int id;
  final String name;
  final int elixirCost;
  final String rarity;
  final int level;
  final int? maxLevel;
  final String? iconUrl;
  final bool isEvolution;

  const CardModel({
    required this.id,
    required this.name,
    required this.elixirCost,
    required this.rarity,
    required this.level,
    this.maxLevel,
    this.iconUrl,
    this.isEvolution = false,
  });

  factory CardModel.fromApiJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      elixirCost: json['elixirCost'] as int? ?? 0,
      rarity: json['rarity'] as String? ?? 'common',
      level: json['level'] as int? ?? 1,
      maxLevel: json['maxLevel'] as int?,
      iconUrl: (json['iconUrls'] as Map<String, dynamic>?)?['medium'] as String?,
      isEvolution: json['evolutionLevel'] != null,
    );
  }

  @override
  String toString() => '$name(lvl$level${isEvolution ? '+evo' : ''})';
}
