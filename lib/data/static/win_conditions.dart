// Bir destenin "win condition"i: rakibin kulesini yikan ana hasar kart.
// Birden fazla varsa en yuksek elixir maliyetli olan secilir.
// Liste, MVP icin elle derlendi. Faz 3'te genisletilecek.

const Set<String> winConditionCardNames = {
  // Cycle / hızlı oyuncular
  'Hog Rider',
  'Royal Hogs',
  'Battle Ram',
  'Ram Rider',
  'Wall Breakers',

  // Kuşatma (siege)
  'X-Bow',
  'Mortar',

  // Beatdown (yavaş + ağır)
  'Golem',
  'Giant',
  'Royal Giant',
  'Mega Knight',
  'Electro Giant',
  'Lava Hound',
  'P.E.K.K.A',
  'Goblin Giant',

  // Spell / bait
  'Goblin Barrel',
  'Graveyard',
  'Skeleton Barrel',

  // Yeni / champion
  'Goblin Drill',
  'Sparky',
};
