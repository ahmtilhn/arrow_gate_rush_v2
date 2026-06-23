import 'package:flame/components.dart';

import '../../../generated/arrow_gate_assets.dart';
import '../../bootstrap/game_asset_loader.dart';

class CoinBadgeComponent extends SpriteComponent with HasGameReference {
  CoinBadgeComponent({required super.position})
    : super(size: Vector2(96, 42), anchor: Anchor.topRight);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(flameAssetKey(ArrowGateAssets.uiHudCoinCounter)),
    );
  }
}
