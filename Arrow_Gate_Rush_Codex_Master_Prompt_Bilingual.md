# Arrow Gate Rush — Codex Master Prompt (Bilingual)

This file is the repository-level source of truth for implementation decisions. The English technical rules are authoritative when translations differ. Planning documents may clarify these rules but may not weaken them.

Bu dosya, uygulama kararları için depo seviyesindeki ana kaynaktır. Çeviriler arasında fark varsa İngilizce teknik kurallar geçerlidir. Planlama belgeleri bu kuralları açıklayabilir ancak zayıflatamaz.

---

# TÜRKÇE

## 1. Ürün hedefi

Flutter ve Flame ile Android/iOS için dikey ekranda çalışan, üretim kalitesinde 2D casual puzzle oyunu geliştir. Oyun 60 FPS hedeflemeli; deterministik, test edilebilir ve yerelleştirilebilir olmalıdır. Kullanıcıya gösterilen hiçbir metin widget veya Flame component içinde hard-code edilmemelidir.

## 2. Değiştirilemez oyun mekaniği

Tahtada kırmızı, mavi, yeşil ve sarı oklar bulunur. Her okun yönü sabittir: yukarı, aşağı, sol veya sağ. Tahtanın dört kenarında birbirinden bağımsız kapı şeritleri vardır.

Bir oka dokunulduğunda ok yalnızca aşağıdaki koşulların tamamı doğruysa çıkabilir:

1. Okun baktığı yönde bulunduğu hücre ile hedef kenar arasındaki bütün hücreler boştur.
2. Hedef kenardaki tam karşılık gelen satır/sütun slotunda kapı vardır.
3. Kapının rengi okun rengiyle aynıdır.
4. Kapı açık ve kilitsizdir.
5. Oyun dokunmayı kabul eden durumdadır.
6. Dokunma, kararlı hizalanma veya tanımlı tap-buffer penceresi içindedir.

Yön/kenar eşleşmesi:

- Yukarı ok → üst kapı şeridi, slot = sütun
- Aşağı ok → alt kapı şeridi, slot = sütun
- Sol ok → sol kapı şeridi, slot = satır
- Sağ ok → sağ kapı şeridi, slot = satır

Aynı kenarda fakat başka satır/sütunda bulunan kapı hizalı değildir. Yol kapalıysa doğru renkli kapı bile çıkış sağlamaz. Yanlış renk, boş slot veya kilitli kapı geçerli hamle değildir. Ok normal hamlede yön değiştirmez.

## 3. Dokunma sonuçları

Saf Dart çekirdeği genel boolean yerine yapılandırılmış sonuç üretmelidir:

- validExit
- pathBlocked
- noGateAligned
- wrongGateColor
- gateLocked
- invalidGamePhase
- tapTooEarly
- tapTooLate
- tapBuffered
- arrowNotFound

Her sonuç debug bilgisi taşımalı; kullanıcıya gösterilecek çevrilebilir metin çekirdek katmanda bulunmamalıdır.

## 4. Oyun durumları

Minimum durumlar:

- booting/loadingAssets
- tutorial
- ready
- evaluatingTap
- arrowLaunching
- resolvingEffects
- gateRotating
- paused
- backgrounded
- levelComplete
- levelFailed
- adShowing (ileriki faz)

Doğrudan dokunma normalde yalnızca ready durumunda kabul edilir. Görsel animasyonlar kural kararını veremez; tek yetkili doğrulama saf Dart MoveValidator ve TapBufferSystem olmalıdır.

## 5. Kapı hareketi ve zamanlama

Dört kenarın kapı şeritleri bağımsızdır. Mantıksal rotasyon frame-rate'e bağlı olmamalıdır. Görsel hareket mevcut commit edilmiş slotlardan sonraki commit edilmiş slotlara animasyon yapmalı, animasyon sonunda tam merkezlere snap etmelidir.

Phase 2 prototip varsayılanları:

- Kapı aralığı: 3 saniye
- Görsel kayma: yaklaşık 350 ms
- Tap buffer: 150 ms, tek merkezî ayardan
- Ok uçuşu sırasında gelen en fazla bir kapı tick'i kuyruğa alınır
- Aynı anda iki kapı animasyonu çalışmaz

## 6. Bir oka basıldığında

1. Aktif component ve input lock doğrulanır.
2. Arrow ID ve zaman damgası controller'a gönderilir.
3. Controller TapAttempt oluşturur.
4. TapBufferSystem zamanlama kararını verir.
5. MoveValidator yol, hizalama, kapı ve renk kurallarını değerlendirir.
6. Sonuç dönmeden ok optimistik olarak hareket etmez.
7. validExit ise ok kısa pulse yapar, hizalı kapı parlar, yol glow alır, ok kendi yönünde tam kapıya gider, kapı burst efekti oynar, ok kaldırılır ve çekirdek state commit edilir.
8. pathBlocked ise ok sallanır, ilk engel ve yol kırmızı/turuncu feedback alır.
9. noGateAligned ise beklenen boş slot yanıp söner.
10. wrongGateColor ise yalnızca hizalı yanlış kapı hata feedback'i alır.
11. gateLocked ise kapı ve kilit metalik pulse/shake yapar.
12. Penalize edilen hatalarda can azalır; invalidGamePhase, duplicate input ve iç hata oyuncuyu cezalandırmaz.

## 7. Kazanma/kaybetme

Kazanma yalnızca son gerekli okun uçuşu tamamlanıp kaldırılması state'e commit edildikten sonra hesaplanır. Can sıfıra düştüğünde kaybetme oluşur. Kazanma ve kaybetme aynı anda oluşamaz; son geçerli hamle tamamlanması, aynı frame'deki gecikmiş hata sinyalinden önceliklidir.

## 8. Bölümler ve generator

İlk 50 bölüm handcrafted/designer-assisted olabilir. İlk 100 bölüm solver ile doğrulanmalıdır. Procedural generator random fill-and-hope kullanamaz. Önce çözüm sırası ve zamanlama pencereleri oluşturulur, tahta ters sırada kurulur, ardından bağımsız solver çözülebilirliği ve difficulty estimator zorluğu doğrular.

Her bölüm için en az bir çözüm, makul bekleme süresi ve görünür adil zamanlama penceresi bulunmalıdır. Daily Challenge seed ile deterministik olmalıdır.

## 9. Görsel kaynaklar

`assets/arrow_gate_rush/`, `config/asset_catalog.json`, `config/screen_asset_map.json` ve `lib/generated/arrow_gate_assets.dart` bağlayıcıdır.

- Asset yolu tahmin etme; generated sabitleri kullan.
- Default Material ikon/buton, emoji veya düz placeholder kullanma.
- Arrow için mevcut yön-spesifik sprite'ı kullan; tek sprite'ı runtime'da döndürme.
- Aspect ratio'yu koru; tint/recolor yapma.
- Metin içeren baked görselleri final lokalize UI metni olarak kullanma.
- Kaynak sprite sheet'leri runtime asset olarak kullanma.
- Şeffaflık, checkerboard, beyaz kutu, halo, clipping ve stretching canlı build ekranında kontrol edilmelidir.

## 10. UI/UX kapsamı

Nihai ürün şu ekranları içerir: splash/loading, ana menü, mod seçimi, bölüm seçimi, gameplay, pause, tutorial, level complete, level failed, daily challenge, shop, settings, privacy/consent, leaderboard/achievements ve satın alma geri yükleme akışı.

Dokunma hedefleri Android'de en az 48 dp, iOS'ta yaklaşık 44 pt olmalıdır. Renk tek başına durum iletmemelidir. Reduce Motion desteği verilmelidir. Aktif gameplay ortasında reklam gösterilmemelidir.

## 11. Ekonomi

Coin yumuşak para; gem premium/seyrek paradır. Kaynaklar ve harcama noktaları veriyle dengelenmelidir. Hint, undo, revive ve kozmetik satın alımları oyuncuyu zorunlu reklama itmemeli; kayıp aversion veya sahte aciliyet kullanılmamalıdır. Ekonomi ve IAP Phase 2 kapsamına girmez.

## 12. Reklam ve platform servisleri

İleriki fazlarda:

- AdMob tek reklam yüzeyidir.
- Unity Ads yalnızca AdMob mediation üzerinden çalışır; doğrudan Unity reklam çağrısı yoktur.
- Meta Audience Network yalnızca AdMob mediation üzerinden çalışır.
- Meta App Events ayrı, consent-aware analytics/attribution servisidir.
- UMP her launch'ta güncellenir; iOS ATT doğru sırada gösterilir.
- Debug build test reklam kimlikleri kullanır.
- Rewarded: hint/undo/life/double reward gibi açık değer değişimi için.
- Interstitial: active gameplay dışında, kontrollü frekansta.
- Banner: yalnızca gameplay dışı uygun ekranlarda.

Play Games, Game Center, Saved Games, IAP, review/update ve cloud save ayrı fazlarda uygulanır; Phase 2'de başlatılmaz.

## 13. Lokalizasyon

Tek düzenlenebilir kaynak `localization/source_strings.yaml` olmalıdır. Buradan ARB, Android `strings.xml`/`plurals.xml`, iOS `Localizable.strings`/`.stringsdict`, keys JSON ve katalog CSV üretilir.

Flutter runtime UI'ın ana kaynağı ARB/AppLocalizations'dır. Android kaynakları Google Play Gemini app-string translation ve native Android yüzeyleri için üretilir. Kullanıcıya gösterilen tüm metinler string kataloğunda olmalıdır.

## 14. Test ve doğruluk

Her fazda `flutter analyze` ve `flutter test` çalışmalıdır. Move validation, path, gate rotation, tap buffer sınırları, state reducer, solver, deterministic seed, asset çözümleme, layout ve lifecycle test edilmelidir.

Testte asset kopyalanarak oluşturulan PNG, çalışan uygulama screenshot'ı diye sunulamaz. Runtime screenshot yalnızca emülatör/cihaz framebuffer'ından (`adb exec-out screencap -p` veya iOS simulator eşdeğeri) alınır ve capture metadata ile belgelenir.

---

# ENGLISH

## 1. Product objective

Build a production-oriented portrait 2D casual puzzle game for Android and iOS using Flutter and Flame. Target stable 60 FPS. The game must be deterministic, testable, localizable, and store-policy compliant. No user-facing string may be hardcoded inside a widget or Flame component.

## 2. Immutable core mechanic

The board contains red, blue, green, and yellow arrows with fixed directions. Four independent gate lanes surround the board.

A tapped arrow may exit only when all conditions are true:

1. Every forward cell between the arrow and its destination edge is clear.
2. A gate occupies the exact corresponding row/column slot on that edge.
3. The aligned gate color matches the arrow color.
4. The gate is open and unlocked.
5. The game is in a tap-accepting phase.
6. The tap is inside a stable or configured buffered timing window.

Mapping:

- Up → top lane, slot = column
- Down → bottom lane, slot = column
- Left → left lane, slot = row
- Right → right lane, slot = row

A gate on the correct edge but another slot is not aligned. Correct color cannot bypass a blocker. Wrong-color, empty, or locked slots are invalid. Normal moves never rotate the arrow itself.

## 3. Authoritative architecture

Pure Dart owns board state, rules, timing decisions, lives, outcomes, and deterministic transitions. GameplayController is the only bridge between Flame input and the core. Flame components own rendering, hit testing, effects, and animation only. There must be exactly one authoritative move-validation path: MoveValidator plus TapBufferSystem.

## 4. Input and feedback

Do not move an arrow before receiving a valid core result. Distinguish validExit, pathBlocked, noGateAligned, wrongGateColor, gateLocked, invalidGamePhase, tapTooEarly, tapTooLate, tapBuffered, and arrowNotFound.

Successful sequence: pulse arrow, glow aligned gate/path, fly in the fixed direction, pass through the exact gate, play gate burst, remove visually, commit core removal, then evaluate completion.

Invalid feedback must target the specific cause. Internal duplicate/phase errors do not cost a life.

## 5. Gates and timing

Each edge has an independent deterministic lane. Logical rotation never depends on FPS. Visual movement interpolates between committed states and snaps to exact slot centers at commit. Centralize the Phase 2 prototype values: 3 s interval, about 350 ms slide, 150 ms tap buffer, maximum one queued gate tick during move resolution.

## 6. Level outcome and generation

Completion occurs only after the final required arrow removal is committed. Failure occurs at zero lives or mode-specific configured conditions. Completion and failure cannot occur simultaneously.

Procedural levels must be solution-first/reverse-constructed and solver-verified. Never use random fill-and-hope. Daily Challenge uses a deterministic shared seed.

## 7. Assets and presentation

The supplied Codex-ready package and generated asset constants are binding. Never invent paths, use source sheets at runtime, replace the style with default Material graphics, rotate a sprite when direction-specific art exists, distort aspect ratio, or silently conceal alpha defects. Live runtime captures are required for visual acceptance.

## 8. Localization

Use `localization/source_strings.yaml` as the canonical editable catalog. Generate Flutter ARB/AppLocalizations, Android string/plural resources for native UI and Google Play Gemini translation compatibility, iOS string/stringdict resources, keys JSON, and CSV. ARB/AppLocalizations remains the primary Flutter runtime source.

## 9. Monetization and privacy

AdMob is the only ad-serving surface. Unity Ads and Meta Audience Network are mediation adapters only. Meta App Events is a separate consent-aware analytics layer. UMP/ATT sequencing is mandatory. Never show banner/interstitial ads during active gameplay. Monetization and platform services are not part of Phase 2.

## 10. Phase discipline and evidence

Do not start a later phase without explicit instruction. Preserve earlier tests. Run analysis/tests and report actual output. Generated fixture previews are not runtime screenshots. Runtime evidence must come from a real emulator/device framebuffer with non-fabricated capture metadata. When an emulator is unavailable, implement the complete capture workflow, report the blocker, and state: **Phase 2 implemented but not fully accepted.**
