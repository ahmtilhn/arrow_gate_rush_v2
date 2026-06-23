import 'package:flame/cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../game_core/game_core.dart';
import '../../generated/arrow_gate_assets.dart';
import '../mapping/arrow_asset_resolver.dart';
import '../mapping/gate_asset_resolver.dart';

String flameAssetKey(String assetPath) {
  return assetPath.startsWith('assets/')
      ? assetPath.substring('assets/'.length)
      : assetPath;
}

class GameAssetLoader {
  GameAssetLoader({
    Images? images,
    this.arrowResolver = const ArrowAssetResolver(),
    this.gateResolver = const GateAssetResolver(),
  }) : images = images ?? Images();

  final Images images;
  final ArrowAssetResolver arrowResolver;
  final GateAssetResolver gateResolver;

  static const requiredAssets = <String>[
    ArrowGateAssets.backgroundsParallaxSkyFull,
    ArrowGateAssets.backgroundsParallaxMountainHorizonStrip,
    ArrowGateAssets.backgroundsParallaxTreeLineStrip,
    ArrowGateAssets.backgroundsParallaxBushLineStrip,
    ArrowGateAssets.backgroundsParallaxForegroundGardenStrip,
    ArrowGateAssets.gameplayBoardCellsEmptyBeigeCompact,
    ArrowGateAssets.gameplayBoardCellsEmptyBeigeLarge,
    ArrowGateAssets.gameplayObstaclesStoneCompact,
    ArrowGateAssets.gameplayObstaclesIceCompact,
    ArrowGateAssets.gameplayObstaclesChainLockedCompact,
    ArrowGateAssets.gameplayPortalsCompactBlue,
    ArrowGateAssets.gameplayPortalsCompactPurple,
    ArrowGateAssets.effectsGateBurstGoldLarge,
    ArrowGateAssets.effectsWrongTapCrossRed,
    ArrowGateAssets.effectsSmokePuffGray,
    ArrowGateAssets.effectsPathGlowHorizontalShort,
    ArrowGateAssets.effectsPathGlowVerticalStrip,
    ArrowGateAssets.uiHudLevelBadge,
    ArrowGateAssets.uiHudCoinCounter,
    ArrowGateAssets.uiButtonsGameplaySettingsNormal,
    ArrowGateAssets.uiButtonsCommonPillGreen,
    ArrowGateAssets.uiButtonsCommonPillBlue,
    ArrowGateAssets.uiButtonsCommonPillRed,
  ];

  Future<void> preload() async {
    final assets = <String>{...requiredAssets};
    for (final color in ArrowColor.values) {
      for (final direction in ArrowDirection.values) {
        assets.add(arrowResolver.resolve(color, direction));
      }
      assets
        ..add(gateResolver.resolve(color, locked: false))
        ..add(gateResolver.resolve(color, locked: true));
    }
    for (final asset in assets) {
      try {
        await rootBundle.load(asset);
        await images.load(flameAssetKey(asset));
      } catch (error, stackTrace) {
        debugPrint('Phase2 asset preload failed: $asset $error\n$stackTrace');
        rethrow;
      }
    }
  }
}
