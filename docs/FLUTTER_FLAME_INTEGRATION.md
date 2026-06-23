# Flutter / Flame Integration
```yaml
flutter:
  assets:
    - assets/arrow_gate_rush/
```

Flutter: `Image.asset(ArrowGateAssets.uiButtonsMainMenuPlayNormal, fit: BoxFit.contain)`

Flame: remove the `assets/` prefix when calling `Sprite.load`, depending on your Flame asset prefix configuration.

Use typed lookup maps for color/direction; do not concatenate unchecked strings.
