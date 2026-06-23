import 'package:flame/components.dart';

import '../../../generated/arrow_gate_assets.dart';
import '../../bootstrap/game_asset_loader.dart';

class GardenBackgroundComponent extends PositionComponent
    with HasGameReference {
  @override
  Future<void> onLoad() async {
    final layers = [
      ArrowGateAssets.backgroundsParallaxSkyFull,
      ArrowGateAssets.backgroundsParallaxMountainHorizonStrip,
      ArrowGateAssets.backgroundsParallaxTreeLineStrip,
      ArrowGateAssets.backgroundsParallaxBushLineStrip,
      ArrowGateAssets.backgroundsParallaxForegroundGardenStrip,
    ];
    for (var i = 0; i < layers.length; i += 1) {
      add(
        SpriteComponent(
          sprite: Sprite(game.images.fromCache(flameAssetKey(layers[i]))),
          size: game.size,
          position: Vector2.zero(),
          priority: i,
        ),
      );
    }
  }
}
