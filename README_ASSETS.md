# Arrow Gate Rush — Codex-Ready Asset Package

Bu paket 186 adet tekil, RGBA PNG asset içerir. Dosya adları ve klasör yolları Codex'in tahmin yapmadan kullanabileceği şekilde düzenlenmiştir.

## Zorunlu kullanım
1. `config/screen_asset_map.json` dosyasındaki kesin ekran eşleşmelerini kullan.
2. Dart içinde `lib/generated/arrow_gate_assets.dart` sabitlerini kullan.
3. Default Material icon/button kullanma.
4. PNG'leri tint/recolor/crop yapma; aspect ratio koru.
5. Normal/pressed buton çiftlerini birlikte kullan.
6. Tüm runtime dosyaları şeffaf kenarlı RGBA PNG'dir.

## Kurulum
- `assets/arrow_gate_rush/` klasörünü Flutter projesine kopyala.
- generated Dart dosyasını `lib/generated/` altına kopyala.
- `config/pubspec_assets_snippet.yaml` içeriğini pubspec'e ekle.
- `CODEX_ASSET_INSTRUCTIONS.md` dosyasını Codex'e okut.
