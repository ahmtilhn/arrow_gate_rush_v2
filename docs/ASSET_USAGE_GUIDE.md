# Asset Usage Guide

## Gameplay
- `gameplay/arrows/<color>/<direction>.png`: ArrowTileComponent. Hücrenin %82–88'i.
- `gameplay/gates/large/open/<color>.png`: dönen gate lane. Gate merkezi row/column merkeziyle tam hizalı.
- `gameplay/gates/large/locked/<color>.png`: aynı renk key toplanana kadar kapalı.
- `gameplay/keys/<color>.png`: aynı renk kapıyı açar.
- `gameplay/obstacles/*`: path kontrolünde engel.
- `gameplay/portals/*`: level datasında çift halinde kullanılır.

## Button state
Normal PNG idle state, pressed PNG pointer-down state. Text gerekiyorsa Flutter Text overlay kullan; PNG üzerine yeni metin çizme.

## Effects
Valid: target ring → arrow launch → gate burst. Invalid: arrow shake → red cross/broken arrow. Reward: coin burst/star trail. Loading: loading dots.

## Background z-order
1 sky, 2 mountain, 3 trees, 4 bushes, 5 foreground garden, 6 decor, 7 light/shadow overlays, 8 game/UI.

## Fit
Gameplay/UI: BoxFit.contain. Full background: BoxFit.cover. No tinting. No arbitrary clipping.
