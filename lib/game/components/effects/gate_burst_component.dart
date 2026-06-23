import 'package:flame/components.dart';

import '../../../generated/arrow_gate_assets.dart';
import '../../bootstrap/game_asset_loader.dart';

class GateBurstComponent extends SpriteComponent with HasGameReference {
  GateBurstComponent({required super.position, required double size})
    : super(size: Vector2.all(size), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(
        flameAssetKey(ArrowGateAssets.effectsGateBurstGoldLarge),
      ),
    );
  }
}
