import '../../game_core/game_core.dart';
import '../../generated/arrow_gate_assets.dart';

class ArrowAssetResolver {
  const ArrowAssetResolver();

  String resolve(ArrowColor color, ArrowDirection direction) {
    return switch ((color, direction)) {
      (ArrowColor.red, ArrowDirection.up) =>
        ArrowGateAssets.gameplayArrowsRedUp,
      (ArrowColor.red, ArrowDirection.down) =>
        ArrowGateAssets.gameplayArrowsRedDown,
      (ArrowColor.red, ArrowDirection.left) =>
        ArrowGateAssets.gameplayArrowsRedLeft,
      (ArrowColor.red, ArrowDirection.right) =>
        ArrowGateAssets.gameplayArrowsRedRight,
      (ArrowColor.blue, ArrowDirection.up) =>
        ArrowGateAssets.gameplayArrowsBlueUp,
      (ArrowColor.blue, ArrowDirection.down) =>
        ArrowGateAssets.gameplayArrowsBlueDown,
      (ArrowColor.blue, ArrowDirection.left) =>
        ArrowGateAssets.gameplayArrowsBlueLeft,
      (ArrowColor.blue, ArrowDirection.right) =>
        ArrowGateAssets.gameplayArrowsBlueRight,
      (ArrowColor.green, ArrowDirection.up) =>
        ArrowGateAssets.gameplayArrowsGreenUp,
      (ArrowColor.green, ArrowDirection.down) =>
        ArrowGateAssets.gameplayArrowsGreenDown,
      (ArrowColor.green, ArrowDirection.left) =>
        ArrowGateAssets.gameplayArrowsGreenLeft,
      (ArrowColor.green, ArrowDirection.right) =>
        ArrowGateAssets.gameplayArrowsGreenRight,
      (ArrowColor.yellow, ArrowDirection.up) =>
        ArrowGateAssets.gameplayArrowsYellowUp,
      (ArrowColor.yellow, ArrowDirection.down) =>
        ArrowGateAssets.gameplayArrowsYellowDown,
      (ArrowColor.yellow, ArrowDirection.left) =>
        ArrowGateAssets.gameplayArrowsYellowLeft,
      (ArrowColor.yellow, ArrowDirection.right) =>
        ArrowGateAssets.gameplayArrowsYellowRight,
    };
  }
}
