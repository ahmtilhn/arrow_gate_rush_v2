import 'package:flame/components.dart';

import '../../../generated/arrow_gate_assets.dart';
import '../../bootstrap/game_asset_loader.dart';

class BlockedPathEffectComponent extends SpriteComponent with HasGameReference {
  BlockedPathEffectComponent({required super.position, required super.size})
    : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(
        flameAssetKey(ArrowGateAssets.effectsPathGlowHorizontalShort),
      ),
    );
  }
}
