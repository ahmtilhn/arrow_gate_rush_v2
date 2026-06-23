import 'package:flame/components.dart';

import '../../../generated/arrow_gate_assets.dart';
import '../../bootstrap/game_asset_loader.dart';

class LevelBadgeComponent extends SpriteComponent with HasGameReference {
  LevelBadgeComponent({required super.position})
    : super(size: Vector2(96, 42), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(flameAssetKey(ArrowGateAssets.uiHudLevelBadge)),
    );
  }
}
