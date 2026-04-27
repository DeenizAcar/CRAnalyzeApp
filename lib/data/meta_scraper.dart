import 'package:http/http.dart' as http;

import 'static/meta_decks.dart';

/// RoyaleAPI'nin /decks/popular sayfasindan top meta destelerini scrape eder.
///
/// HTML su yapida:
///   <div data-deck-name="card1,card2-ev1,card3-hero,...,card8"></div>
///
/// Kart adlari kebab-case + ozel suffix:
///   -ev1 / -ev2 = evolution
///   -hero       = champion (heroMedium icon)
///
/// Notlar:
///   - Kategori: Ranked (yani Path of Legends + Master Tier dahil)
///   - Min trophies degil; max_trophies ile pro seviyeyi filtreliyoruz
///   - Surekli 1d/7d zaman aralikli sorgulama yapilabilir
class MetaScraper {
  static const String _baseUrl = 'https://royaleapi.com/decks/popular';

  final http.Client _http;
  final List<String> _availableCardNames;

  MetaScraper({
    required List<String> availableCardNames,
    http.Client? httpClient,
  })  : _availableCardNames = availableCardNames,
        _http = httpClient ?? http.Client();

  /// CRL/pro seviye, son 7 gun, top X popularite/rating destelerini cek.
  /// [days] 1 veya 7 olabilir.
  Future<List<MetaDeck>> fetchTopRanked({
    int days = 7,
    int maxTrophies = 20000,
    int limit = 50,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?time=${days}d&cat=Ranked&max_trophies=$maxTrophies&size=$limit&sort=rating',
    );
    final res = await _http.get(url, headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/119',
      'Accept': 'text/html,application/xhtml+xml',
    });
    if (res.statusCode != 200) {
      throw Exception('MetaScraper HTTP ${res.statusCode}');
    }
    return _parse(res.body, limit: limit);
  }

  List<MetaDeck> _parse(String html, {required int limit}) {
    final regex = RegExp(r'data-deck-name="([^"]+)"');
    final results = <MetaDeck>[];
    var rank = 0;
    for (final match in regex.allMatches(html)) {
      final raw = match.group(1)!;
      if (raw.isEmpty) continue;
      final cardSlugs = raw.split(',');
      if (cardSlugs.length != 8) continue;
      final slots = cardSlugs.map(_slugToSlot).whereType<MetaCardSlot>().toList();
      if (slots.length != 8) continue; // bilinmeyen kart varsa atla
      rank++;
      results.add(MetaDeck(
        name: 'Meta #$rank',
        archetype: _guessArchetype(slots.map((s) => s.name).toList()),
        cards: slots,
      ));
      if (results.length >= limit) break;
    }
    return results;
  }

  /// Slug'i kart slot'una cevir (ad + variant).
  /// 'lumberjack-ev1' -> (Lumberjack, evolution)
  /// 'wizard-hero'    -> (Wizard, hero)
  /// 'barbarian-barrel' -> (Barbarian Barrel, normal)
  MetaCardSlot? _slugToSlot(String slug) {
    var s = slug.toLowerCase().trim();
    var variant = CardVariant.normal;
    final evMatch = RegExp(r'-(ev\d)$').firstMatch(s);
    if (evMatch != null) {
      variant = CardVariant.evolution;
      s = s.substring(0, evMatch.start);
    } else if (s.endsWith('-hero') || s.endsWith('-champion')) {
      variant = CardVariant.hero;
      s = s.replaceAll(RegExp(r'-(hero|champion)$'), '');
    }
    final name = _slugToName(s);
    if (name == null) return null;
    return MetaCardSlot(name, variant);
  }

  /// Kebab-case slug'i CR resmi kart adina cevir (variant suffix'siz).
  String? _slugToName(String s) {

    // Ozel durumlar
    const special = {
      'pekka': 'P.E.K.K.A',
      'x-bow': 'X-Bow',
      'eq': 'Earthquake',
      'thelog': 'The Log',
      'log': 'The Log',
      'bbq': 'Barbarian Barrel',
      'mini-pekka': 'Mini P.E.K.K.A',
      'electro-spirit': 'Electro Spirit',
      'electro-wizard': 'Electro Wizard',
      'electro-dragon': 'Electro Dragon',
      'electro-giant': 'Electro Giant',
      'three-musketeers': 'Three Musketeers',
      'goblin-barrel': 'Goblin Barrel',
      'goblin-gang': 'Goblin Gang',
      'goblin-hut': 'Goblin Hut',
      'goblin-cage': 'Goblin Cage',
      'goblin-giant': 'Goblin Giant',
      'goblin-drill': 'Goblin Drill',
      'goblin-machine': 'Goblin Machine',
      'goblin-curse': 'Goblin Curse',
      'goblin-demolisher': 'Goblin Demolisher',
      'royal-giant': 'Royal Giant',
      'royal-recruits': 'Royal Recruits',
      'royal-hogs': 'Royal Hogs',
      'royal-ghost': 'Royal Ghost',
      'royal-delivery': 'Royal Delivery',
      'mega-knight': 'Mega Knight',
      'mega-minion': 'Mega Minion',
      'inferno-tower': 'Inferno Tower',
      'inferno-dragon': 'Inferno Dragon',
      'baby-dragon': 'Baby Dragon',
      'skeleton-army': 'Skeleton Army',
      'skeleton-king': 'Skeleton King',
      'skeleton-barrel': 'Skeleton Barrel',
      'skeleton-dragons': 'Skeleton Dragons',
      'lava-hound': 'Lava Hound',
      'ice-spirit': 'Ice Spirit',
      'ice-golem': 'Ice Golem',
      'ice-wizard': 'Ice Wizard',
      'fire-spirit': 'Fire Spirit',
      'heal-spirit': 'Heal Spirit',
      'night-witch': 'Night Witch',
      'mother-witch': 'Mother Witch',
      'magic-archer': 'Magic Archer',
      'mighty-miner': 'Mighty Miner',
      'wall-breakers': 'Wall Breakers',
      'battle-ram': 'Battle Ram',
      'ram-rider': 'Ram Rider',
      'hog-rider': 'Hog Rider',
      'dart-goblin': 'Dart Goblin',
      'spear-goblins': 'Spear Goblins',
      'cannon-cart': 'Cannon Cart',
      'flying-machine': 'Flying Machine',
      'elite-barbarians': 'Elite Barbarians',
      'barbarian-barrel': 'Barbarian Barrel',
      'barbarian-hut': 'Barbarian Hut',
      'dark-prince': 'Dark Prince',
      'monk': 'Monk',
      'phoenix': 'Phoenix',
      'firecracker': 'Firecracker',
      'tornado': 'Tornado',
      'graveyard': 'Graveyard',
      'rascals': 'Rascals',
      'guards': 'Guards',
      'archer-queen': 'Archer Queen',
      'golden-knight': 'Golden Knight',
      'little-prince': 'Little Prince',
      'boss-bandit': 'Boss Bandit',
      'royal-chef': 'Royal Chef',
      'rune-giant': 'Rune Giant',
      'berserker': 'Berserker',
      'lumberjack': 'Lumberjack',
      'bandit': 'Bandit',
      'bowler': 'Bowler',
      'executioner': 'Executioner',
      'hunter': 'Hunter',
      'musketeer': 'Musketeer',
      'princess': 'Princess',
      'witch': 'Witch',
      'wizard': 'Wizard',
      'valkyrie': 'Valkyrie',
      'knight': 'Knight',
      'archers': 'Archers',
      'goblins': 'Goblins',
      'bomber': 'Bomber',
      'minions': 'Minions',
      'minion-horde': 'Minion Horde',
      'sparky': 'Sparky',
      'tombstone': 'Tombstone',
      'cannon': 'Cannon',
      'tesla': 'Tesla',
      'mortar': 'Mortar',
      'bomb-tower': 'Bomb Tower',
      'furnace': 'Furnace',
      'elixir-collector': 'Elixir Collector',
      'fireball': 'Fireball',
      'rocket': 'Rocket',
      'lightning': 'Lightning',
      'arrows': 'Arrows',
      'zap': 'Zap',
      'poison': 'Poison',
      'freeze': 'Freeze',
      'mirror': 'Mirror',
      'rage': 'Rage',
      'clone': 'Clone',
      'snowball': 'Giant Snowball',
      'giant-snowball': 'Giant Snowball',
      'earthquake': 'Earthquake',
      'the-log': 'The Log',
      'tesla-evolution': 'Tesla',
      'goblin-stadium': 'Goblin Stadium',
      'giant': 'Giant',
      'golem': 'Golem',
      'balloon': 'Balloon',
      'miner': 'Miner',
      'skeletons': 'Skeletons',
      'bats': 'Bats',
      'zappies': 'Zappies',
      'giant-skeleton': 'Giant Skeleton',
      'prince': 'Prince',
    };
    if (special.containsKey(s)) return special[s];

    // Default: kebab -> Title Case
    final titled = s.split('-').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');

    // Bilinen kart adlarinda ara (CardCatalog'dan gelen liste)
    if (_availableCardNames.contains(titled)) return titled;
    // Title yoksa null don, bu kart bilinmiyor
    return null;
  }

  String _guessArchetype(List<String> cards) {
    const beatdownCards = {
      'Golem', 'Lava Hound', 'Electro Giant', 'P.E.K.K.A',
      'Mega Knight', 'Goblin Giant', 'Giant'
    };
    const cycleCards = {'Hog Rider', 'Royal Hogs', 'Battle Ram', 'Ice Spirit'};
    const siegeCards = {'X-Bow', 'Mortar', 'Goblin Drill'};
    const baitCards = {'Goblin Barrel', 'Princess', 'Goblin Gang'};

    if (cards.any(siegeCards.contains)) return 'siege';
    if (cards.any(beatdownCards.contains)) return 'beatdown';
    if (cards.any(baitCards.contains)) return 'bait';
    if (cards.any(cycleCards.contains)) return 'cycle';
    return 'control';
  }

  void dispose() => _http.close();
}
