import 'package:flame/components.dart';

import '../../../generated/arrow_gate_assets.dart';
import '../../bootstrap/game_asset_loader.dart';

class LivesComponent extends PositionComponent with HasGameReference {
  LivesComponent({required this.lives, required super.position});

  int lives;

  @override
  Future<void> onLoad() async {
    refresh(lives);
  }

  void refresh(int nextLives) {
    lives = nextLives;
    removeAll(children.toList());
    for (var i = 0; i < lives; i += 1) {
      add(
        SpriteComponent(
          sprite: Sprite(
            game.images.fromCache(
              flameAssetKey(ArrowGateAssets.uiIconsGemsRed),
            ),
          ),
          position: Vector2(i * 28, 0),
          size: Vector2.all(24),
        ),
      );
    }
  }
}
