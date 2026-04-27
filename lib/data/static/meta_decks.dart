// Meta arketipleri: anti-deck onerirken kullanilacak aday havuz.
// Her deste 8 kart adi icerir; uygulama bu adlarla esleserse skorlar.
// MVP listesi: 12 klasik arketip. Seeok ile beraber genisletilecek.

enum CardVariant { normal, evolution, hero }

class MetaCardSlot {
  final String name;
  final CardVariant variant;
  const MetaCardSlot(this.name, [this.variant = CardVariant.normal]);

  bool get isEvolution => variant == CardVariant.evolution;
  bool get isHero => variant == CardVariant.hero;
}

class MetaDeck {
  final String name;
  final String archetype;
  final List<MetaCardSlot> cards;

  const MetaDeck({
    required this.name,
    required this.archetype,
    required this.cards,
  });

  /// Geriye doneuk: sadece kart adlari (eski API).
  List<String> get cardNames => cards.map((c) => c.name).toList();

  /// Slot sıralaması: evrimler basa, sonra hero/sampiyon, sonra normaller.
  /// Her grupta alfabetik.
  List<MetaCardSlot> get slottedCards {
    final evos = cards.where((c) => c.isEvolution).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final heroes = cards.where((c) => c.isHero).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final normals = cards.where((c) => c.variant == CardVariant.normal).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return [...evos, ...heroes, ...normals];
  }
}

// Statik fallback desteler (scrape basarisiz olursa kullanılır).
const List<MetaDeck> metaDecks = [
  MetaDeck(
    name: 'Mini P.E.K.K.A Hog Cycle',
    archetype: 'cycle',
    cards: [
      MetaCardSlot('Hog Rider'), MetaCardSlot('Mini P.E.K.K.A'),
      MetaCardSlot('Ice Spirit'), MetaCardSlot('Skeletons'),
      MetaCardSlot('The Log'), MetaCardSlot('Fireball'),
      MetaCardSlot('Cannon'), MetaCardSlot('Musketeer'),
    ],
  ),
  MetaDeck(
    name: '2.6 Hog Cycle',
    archetype: 'cycle',
    cards: [
      MetaCardSlot('Hog Rider'), MetaCardSlot('Ice Spirit'),
      MetaCardSlot('Skeletons'), MetaCardSlot('Ice Golem'),
      MetaCardSlot('The Log'), MetaCardSlot('Fireball'),
      MetaCardSlot('Cannon'), MetaCardSlot('Musketeer'),
    ],
  ),
  MetaDeck(
    name: 'X-Bow 2.9',
    archetype: 'siege',
    cards: [
      MetaCardSlot('X-Bow'), MetaCardSlot('Tesla'),
      MetaCardSlot('Ice Golem'), MetaCardSlot('Skeletons'),
      MetaCardSlot('Ice Spirit'), MetaCardSlot('Archers'),
      MetaCardSlot('The Log'), MetaCardSlot('Fireball'),
    ],
  ),
  MetaDeck(
    name: 'Mortar Cycle',
    archetype: 'siege',
    cards: [
      MetaCardSlot('Mortar'), MetaCardSlot('Knight'),
      MetaCardSlot('Skeletons'), MetaCardSlot('Ice Spirit'),
      MetaCardSlot('The Log'), MetaCardSlot('Rocket'),
      MetaCardSlot('Tesla'), MetaCardSlot('Bomber'),
    ],
  ),
  MetaDeck(
    name: 'Golem Beatdown',
    archetype: 'beatdown',
    cards: [
      MetaCardSlot('Golem'), MetaCardSlot('Night Witch'),
      MetaCardSlot('Mega Minion'), MetaCardSlot('Baby Dragon'),
      MetaCardSlot('Lumberjack'), MetaCardSlot('Lightning'),
      MetaCardSlot('Tornado'), MetaCardSlot('Barbarian Barrel'),
    ],
  ),
  MetaDeck(
    name: 'LavaLoon',
    archetype: 'air-beatdown',
    cards: [
      MetaCardSlot('Lava Hound'), MetaCardSlot('Balloon'),
      MetaCardSlot('Mega Minion'), MetaCardSlot('Minions'),
      MetaCardSlot('Tombstone'), MetaCardSlot('Fireball'),
      MetaCardSlot('Zap'), MetaCardSlot('Inferno Dragon'),
    ],
  ),
  MetaDeck(
    name: 'Royal Giant Lightning',
    archetype: 'control',
    cards: [
      MetaCardSlot('Royal Giant'), MetaCardSlot('Lightning'),
      MetaCardSlot('Hunter'), MetaCardSlot('Lumberjack'),
      MetaCardSlot('Skeleton Dragons'), MetaCardSlot('Phoenix'),
      MetaCardSlot('Skeletons'), MetaCardSlot('The Log'),
    ],
  ),
  MetaDeck(
    name: 'Mega Knight Bait',
    archetype: 'bait',
    cards: [
      MetaCardSlot('Mega Knight'), MetaCardSlot('Inferno Dragon'),
      MetaCardSlot('Goblin Gang'), MetaCardSlot('Goblin Barrel'),
      MetaCardSlot('Princess'), MetaCardSlot('Bats'),
      MetaCardSlot('The Log'), MetaCardSlot('Rocket'),
    ],
  ),
  MetaDeck(
    name: 'P.E.K.K.A Bridge Spam',
    archetype: 'bridge-spam',
    cards: [
      MetaCardSlot('P.E.K.K.A'), MetaCardSlot('Bandit'),
      MetaCardSlot('Battle Ram'), MetaCardSlot('Royal Ghost'),
      MetaCardSlot('Electro Wizard'), MetaCardSlot('Magic Archer'),
      MetaCardSlot('Zap'), MetaCardSlot('Poison'),
    ],
  ),
  MetaDeck(
    name: 'Graveyard Control',
    archetype: 'control',
    cards: [
      MetaCardSlot('Graveyard'), MetaCardSlot('Knight'),
      MetaCardSlot('Bowler'), MetaCardSlot('Tornado'),
      MetaCardSlot('Ice Wizard'), MetaCardSlot('Baby Dragon'),
      MetaCardSlot('Poison'), MetaCardSlot('The Log'),
    ],
  ),
  MetaDeck(
    name: 'Electro Giant Sparky',
    archetype: 'beatdown',
    cards: [
      MetaCardSlot('Electro Giant'), MetaCardSlot('Sparky'),
      MetaCardSlot('Lightning'), MetaCardSlot('Tornado'),
      MetaCardSlot('Phoenix'), MetaCardSlot('Mega Minion'),
      MetaCardSlot('Bats'), MetaCardSlot('Zap'),
    ],
  ),
  MetaDeck(
    name: 'Royal Hogs Earthquake',
    archetype: 'cycle',
    cards: [
      MetaCardSlot('Royal Hogs'), MetaCardSlot('Earthquake'),
      MetaCardSlot('Bomber'), MetaCardSlot('Royal Recruits'),
      MetaCardSlot('Wizard'), MetaCardSlot('Zap'),
      MetaCardSlot('Barbarian Barrel'), MetaCardSlot('Goblin Cage'),
    ],
  ),
];
