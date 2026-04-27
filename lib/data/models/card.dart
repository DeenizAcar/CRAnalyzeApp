class CardModel {
  final int id;
  final String name;
  final int elixirCost;
  final String rarity;
  final int level;
  final int? maxLevel;
  final String? iconUrl;
  final String? evolutionIconUrl;
  final String? heroIconUrl;
  final bool isEvolution;

  const CardModel({
    required this.id,
    required this.name,
    required this.elixirCost,
    required this.rarity,
    required this.level,
    this.maxLevel,
    this.iconUrl,
    this.evolutionIconUrl,
    this.heroIconUrl,
    this.isEvolution = false,
  });

  bool get isChampion => rarity.toLowerCase() == 'champion';

  String? get displayIconUrl {
    if (isEvolution && evolutionIconUrl != null) return evolutionIconUrl;
    if (isChampion && heroIconUrl != null) return heroIconUrl;
    return iconUrl;
  }

  factory CardModel.fromApiJson(Map<String, dynamic> json) {
    final icons = json['iconUrls'] as Map<String, dynamic>?;
    return CardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      elixirCost: json['elixirCost'] as int? ?? 0,
      rarity: json['rarity'] as String? ?? 'common',
      level: json['level'] as int? ?? 1,
      maxLevel: json['maxLevel'] as int?,
      iconUrl: icons?['medium'] as String?,
      evolutionIconUrl: icons?['evolutionMedium'] as String?,
      heroIconUrl: icons?['heroMedium'] as String?,
      isEvolution: json['evolutionLevel'] != null,
    );
  }

  @override
  String toString() => '$name(lvl$level${isEvolution ? '+evo' : ''})';
}
