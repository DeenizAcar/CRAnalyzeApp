// Kart kategorileri: bir destenin "neye karsi guclu/zayif" oldugunu hesaplamak icin.
// Her kart birden fazla kategoriye girebilir.
// Liste MVP: Seeok ve takimla kalibre edilmesi beklenir.

enum CardCategory {
  /// Havadaki birimleri vuran kartlar (Lava Hound/Balloon/Minion'a karsi).
  airDefense,

  /// Alan hasari veren kartlar (swarm/iskelet ordusuna karsi).
  splash,

  /// Tank counter / yuksek tek hedef DPS (Golem/PEKKA'ya karsi).
  tankKiller,

  /// Defansif kucuk binalar (cycle/Hog'a karsi tank cekme).
  defensiveBuilding,

  /// Bina/swarm vuran spelt (kuleye/savunmaya karsi).
  spell,

  /// Karsi kuleyi yikabilen kartlar (win condition).
  winCondition,
}

const Map<String, Set<CardCategory>> cardCategories = {
  // ===== Hava savunmasi =====
  'Minions': {CardCategory.airDefense},
  'Minion Horde': {CardCategory.airDefense},
  'Mega Minion': {CardCategory.airDefense},
  'Musketeer': {CardCategory.airDefense, CardCategory.tankKiller},
  'Three Musketeers': {CardCategory.airDefense, CardCategory.tankKiller},
  'Archers': {CardCategory.airDefense},
  'Hunter': {CardCategory.airDefense, CardCategory.tankKiller},
  'Inferno Dragon': {CardCategory.airDefense, CardCategory.tankKiller},
  'Tesla': {CardCategory.airDefense, CardCategory.defensiveBuilding},
  'Phoenix': {CardCategory.airDefense},
  'Spear Goblins': {CardCategory.airDefense},
  'Dart Goblin': {CardCategory.airDefense},
  'Electro Wizard': {CardCategory.airDefense},
  'Electro Dragon': {CardCategory.airDefense, CardCategory.splash},
  'Skeleton Dragons': {CardCategory.airDefense, CardCategory.splash},
  'Wizard': {CardCategory.airDefense, CardCategory.splash},
  'Ice Wizard': {CardCategory.airDefense, CardCategory.splash},
  'Magic Archer': {CardCategory.airDefense, CardCategory.splash},
  'Bats': {CardCategory.airDefense},
  'Firecracker': {CardCategory.airDefense, CardCategory.splash},
  'Zappies': {CardCategory.airDefense},
  'Flying Machine': {CardCategory.airDefense},

  // ===== Alan hasari (splash) =====
  'Bomber': {CardCategory.splash},
  'Valkyrie': {CardCategory.splash},
  'Baby Dragon': {CardCategory.splash, CardCategory.airDefense},
  'Executioner': {CardCategory.splash, CardCategory.airDefense},
  'Bowler': {CardCategory.splash},
  'Witch': {CardCategory.splash, CardCategory.airDefense},
  'Mother Witch': {CardCategory.splash},
  'Dark Prince': {CardCategory.splash},
  'Mega Knight': {CardCategory.splash, CardCategory.tankKiller},
  'Sparky': {CardCategory.splash},
  'Tornado': {CardCategory.splash},
  'The Log': {CardCategory.splash},
  'Zap': {CardCategory.splash},
  'Arrows': {CardCategory.splash, CardCategory.airDefense},
  'Barbarian Barrel': {CardCategory.splash},
  'Earthquake': {CardCategory.splash},
  'Fire Spirit': {CardCategory.splash},
  'Heal Spirit': {CardCategory.splash},
  'Electro Spirit': {CardCategory.splash},

  // ===== Tank killer / yuksek DPS =====
  'Mini P.E.K.K.A': {CardCategory.tankKiller},
  'P.E.K.K.A': {CardCategory.tankKiller},
  'Lumberjack': {CardCategory.tankKiller},
  'Prince': {CardCategory.tankKiller},
  'Inferno Tower': {CardCategory.tankKiller, CardCategory.defensiveBuilding},
  'Skeleton King': {CardCategory.tankKiller, CardCategory.splash},
  'Mighty Miner': {CardCategory.tankKiller},
  'Bandit': {CardCategory.tankKiller},
  'Berserker': {CardCategory.tankKiller},

  // ===== Savunma binalari (kucuk) =====
  'Cannon': {CardCategory.defensiveBuilding},
  'Bomb Tower': {CardCategory.defensiveBuilding, CardCategory.splash},
  'Tombstone': {CardCategory.defensiveBuilding},
  'Goblin Cage': {CardCategory.defensiveBuilding, CardCategory.tankKiller},
  'Goblin Hut': {CardCategory.defensiveBuilding},
  'Furnace': {CardCategory.defensiveBuilding},
  'Barbarian Hut': {CardCategory.defensiveBuilding},
  'Elixir Collector': {CardCategory.defensiveBuilding},

  // ===== Spell (cek-bas) =====
  'Fireball': {CardCategory.spell},
  'Rocket': {CardCategory.spell},
  'Lightning': {CardCategory.spell},
  'Poison': {CardCategory.spell},
  'Freeze': {CardCategory.spell},
  'Rage': {CardCategory.spell},
  'Royal Delivery': {CardCategory.spell},
  'Giant Snowball': {CardCategory.spell},
  'Goblin Curse': {CardCategory.spell},

  // ===== Win condition (saldiran) =====
  'Hog Rider': {CardCategory.winCondition},
  'Royal Hogs': {CardCategory.winCondition},
  'Battle Ram': {CardCategory.winCondition},
  'Ram Rider': {CardCategory.winCondition},
  'Wall Breakers': {CardCategory.winCondition},
  'X-Bow': {CardCategory.winCondition},
  'Mortar': {CardCategory.winCondition},
  'Golem': {CardCategory.winCondition},
  'Giant': {CardCategory.winCondition},
  'Royal Giant': {CardCategory.winCondition},
  'Electro Giant': {CardCategory.winCondition},
  'Lava Hound': {CardCategory.winCondition},
  'Goblin Giant': {CardCategory.winCondition},
  'Goblin Barrel': {CardCategory.winCondition},
  'Graveyard': {CardCategory.winCondition},
  'Skeleton Barrel': {CardCategory.winCondition},
  'Goblin Drill': {CardCategory.winCondition},
  'Balloon': {CardCategory.winCondition},
  'Miner': {CardCategory.winCondition},
};

extension CardCategoryLabel on CardCategory {
  String get tr {
    switch (this) {
      case CardCategory.airDefense:
        return 'Hava savunması';
      case CardCategory.splash:
        return 'Alan hasarı (swarm counter)';
      case CardCategory.tankKiller:
        return 'Tank counter';
      case CardCategory.defensiveBuilding:
        return 'Savunma binası';
      case CardCategory.spell:
        return 'Büyü';
      case CardCategory.winCondition:
        return 'Win condition';
    }
  }

  String get exploit {
    switch (this) {
      case CardCategory.airDefense:
        return 'Hava win condition oyna (Lava Hound, Balloon)';
      case CardCategory.splash:
        return 'Swarm win condition oyna (Goblin Barrel, Skeleton Army, Wall Breakers)';
      case CardCategory.tankKiller:
        return 'Ağır tank oyna (Golem, Mega Knight)';
      case CardCategory.defensiveBuilding:
        return 'Hızlı saldırı / cycle (Hog Rider, Battle Ram)';
      case CardCategory.spell:
        return 'Yoğun savunma (Three Musketeers, Witch)';
      case CardCategory.winCondition:
        return 'Bekle ve karşı saldır (control deck)';
    }
  }
}
