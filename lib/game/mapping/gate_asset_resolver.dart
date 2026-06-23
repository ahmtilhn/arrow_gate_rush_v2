import '../../game_core/game_core.dart';
import '../../generated/arrow_gate_assets.dart';

class GateAssetResolver {
  const GateAssetResolver({this.useCompact = true});

  final bool useCompact;

  String resolve(ArrowColor color, {required bool locked}) {
    if (useCompact) {
      return switch ((color, locked)) {
        (ArrowColor.red, false) => ArrowGateAssets.gameplayGatesCompactOpenRed,
        (ArrowColor.blue, false) =>
          ArrowGateAssets.gameplayGatesCompactOpenBlue,
        (ArrowColor.green, false) =>
          ArrowGateAssets.gameplayGatesCompactOpenGreen,
        (ArrowColor.yellow, false) =>
          ArrowGateAssets.gameplayGatesCompactOpenYellow,
        (ArrowColor.red, true) => ArrowGateAssets.gameplayGatesCompactLockedRed,
        (ArrowColor.blue, true) =>
          ArrowGateAssets.gameplayGatesCompactLockedBlue,
        (ArrowColor.green, true) =>
          ArrowGateAssets.gameplayGatesCompactLockedGreen,
        (ArrowColor.yellow, true) =>
          ArrowGateAssets.gameplayGatesCompactLockedYellow,
      };
    }
    return switch ((color, locked)) {
      (ArrowColor.red, false) => ArrowGateAssets.gameplayGatesLargeOpenRed,
      (ArrowColor.blue, false) => ArrowGateAssets.gameplayGatesLargeOpenBlue,
      (ArrowColor.green, false) => ArrowGateAssets.gameplayGatesLargeOpenGreen,
      (ArrowColor.yellow, false) =>
        ArrowGateAssets.gameplayGatesLargeOpenYellow,
      (ArrowColor.red, true) => ArrowGateAssets.gameplayGatesLargeLockedRed,
      (ArrowColor.blue, true) => ArrowGateAssets.gameplayGatesLargeLockedBlue,
      (ArrowColor.green, true) => ArrowGateAssets.gameplayGatesLargeLockedGreen,
      (ArrowColor.yellow, true) =>
        ArrowGateAssets.gameplayGatesLargeLockedYellow,
    };
  }
}
