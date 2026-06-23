import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../../../game_core/game_core.dart';
import '../../arrow_gate_game.dart';
import '../../bootstrap/game_asset_loader.dart';
import '../../mapping/arrow_asset_resolver.dart';

enum ArrowVisualState {
  idle,
  tappableAligned,
  blocked,
  wrongColorAligned,
  launching,
  disabled,
  removed,
}

class ArrowTileComponent extends SpriteComponent
    with HasGameReference<ArrowGateGame>, TapCallbacks {
  ArrowTileComponent({
    required this.arrow,
    required super.position,
    required double cellSize,
    this.resolver = const ArrowAssetResolver(),
  }) : super(size: Vector2.all(cellSize * 0.86), anchor: Anchor.center);

  final ArrowTile arrow;
  final ArrowAssetResolver resolver;
  ArrowVisualState visualState = ArrowVisualState.idle;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(
        flameAssetKey(resolver.resolve(arrow.color, arrow.direction)),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.handleArrowTap(arrow.id);
  }

  void markAligned() {
    visualState = ArrowVisualState.tappableAligned;
    add(
      ScaleEffect.to(
        Vector2.all(1.08),
        EffectController(duration: 0.18, reverseDuration: 0.18),
      ),
    );
  }

  void shake() {
    add(
      MoveEffect.by(
        Vector2(8, 0),
        EffectController(duration: 0.05, alternate: true, repeatCount: 4),
      ),
    );
  }

  void launchTo(Vector2 target, void Function() onComplete) {
    visualState = ArrowVisualState.launching;
    add(
      MoveEffect.to(
        target,
        EffectController(duration: 0.42),
        onComplete: onComplete,
      ),
    );
  }
}
