import 'package:flame/components.dart';

import '../../../generated/arrow_gate_assets.dart';
import '../../bootstrap/game_asset_loader.dart';

class BoardCellComponent extends SpriteComponent with HasGameReference {
  BoardCellComponent({required super.position, required double cellSize})
    : super(size: Vector2.all(cellSize));

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(
        flameAssetKey(ArrowGateAssets.gameplayBoardCellsEmptyBeigeCompact),
      ),
    );
  }
}
