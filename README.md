# CR Analyze — Clash Royale Anti-Deck Tool

Profesyonel e-spor maçları için Clash Royale rakip analizi ve anti-deck öneri uygulaması. Seeok ile birlikte geliştirilmektedir.

## Ne yapar

Rakip oyuncunun tag'ini girersin (`#XXXXXXXX`), uygulama:
1. Resmi Clash Royale API'den son maçlarını çeker
2. En sık kullandığı desteleri tespit eder
3. AI/kural-tabanlı motoru ile en olası antiden başlayarak öneri listesi üretir

## Stack

- **Flutter** (Windows masaüstü → iOS hedefli, tek kod tabanı)
- **Resmi Supercell Clash Royale API** veri kaynağı olarak
- Kural-tabanlı öneri motoru (LLM upgrade-ready mimari)

## Kurulum

### 1. Bağımlılıklar
```bash
flutter pub get
```

### 2. API token (RoyaleAPI proxy ile takım kullanımı)

9 kişilik takımda her birimizin IP'si farklı olduğundan, **RoyaleAPI'nin ücretsiz proxy** hizmetini kullanıyoruz. Tek token ile herkesin makinesinde çalışır.

1. [developer.clashroyale.com](https://developer.clashroyale.com) → Supercell hesabınla giriş yap
2. **Create New Key** tıkla
3. Anahtar bilgileri:
   - **Name:** `cr-analyze-team` (veya istediğin)
   - **Description:** Anti-deck tool — Seeok team
   - **IP Addresses:** `45.79.218.79` ← **kendi IP'n değil, bu!** (RoyaleAPI proxy IP'si)
4. Üretilen token'ı al
5. `.env.example` dosyasını `.env` olarak kopyala, token'ı yapıştır:

```bash
cp .env.example .env
```

> `.env` dosyası `.gitignore` ile koruma altında — commit edilmemelidir. Token'ı paylaşmak istersen ekibe Discord/güvenli kanaldan ilet.

> **Neden proxy?** Supercell token'ları IP'ye bağlı. Takım çalışmasında ve deploy ortamlarında IP sürekli değişir → her seferinde yeni token üretmek pratik değil. RoyaleAPI proxy bizim için sabit bir IP sağlıyor: `45.79.218.79`. Uygulama otomatik olarak `https://proxy.royaleapi.dev/v1` üzerinden gidiyor.

### 3. Çalıştır

Windows masaüstü:
```bash
flutter run -d windows
```

> Not: Windows derlemesi için Visual Studio'da "Desktop development with C++" workload'ı gerekli (`flutter doctor` ile kontrol et).

Web (test için):
```bash
flutter run -d chrome
```

## Klasör yapısı

```
lib/
├── main.dart                    # Entry point
├── data/
│   ├── api/                     # CR API client + interface
│   ├── cache/                   # Local cache (SQLite vb.)
│   ├── models/                  # Card, Deck, Battle, Player
│   └── static/                  # Statik veri (kart counter ilişkileri)
├── engine/                      # Öneri motoru (kural-tabanlı, LLM)
├── ui/
│   ├── screens/                 # Ana ekranlar
│   └── widgets/                 # Yeniden kullanılabilir bileşenler
└── utils/                       # env, helpers
```

## Yol haritası

- [x] Faz 0: Proje iskeleti
- [ ] Faz 1: v0 — Tag → battlelog → ekranda göster
- [ ] Faz 2: v1 — Kural-tabanlı ilk öneri
- [ ] Faz 3: v2 — Skor zenginleştirme (elixir, meta, win-rate)
- [ ] Faz 4: v3 — Maç geçmişi + Seeok'un kişisel verisi
- [ ] Faz 5: iOS port + LLM upgrade
