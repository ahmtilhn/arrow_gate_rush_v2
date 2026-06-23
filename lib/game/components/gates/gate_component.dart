import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../../../game_core/game_core.dart';
import '../../bootstrap/game_asset_loader.dart';
import '../../mapping/gate_asset_resolver.dart';

class GateComponent extends SpriteComponent with HasGameReference {
  GateComponent({
    required this.gate,
    required this.edge,
    required this.slotIndex,
    required super.position,
    required double cellSize,
    this.resolver = const GateAssetResolver(),
  }) : super(size: Vector2.all(cellSize), anchor: Anchor.center);

  final GateSlot gate;
  final GateEdge edge;
  final int slotIndex;
  final GateAssetResolver resolver;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache(
        flameAssetKey(resolver.resolve(gate.color, locked: gate.isLocked)),
      ),
    );
    angle = switch (edge) {
      GateEdge.top => 0,
      GateEdge.bottom => 3.141592653589793,
      GateEdge.left => 1.5707963267948966,
      GateEdge.right => -1.5707963267948966,
    };
  }

  void pulse() {
    add(
      ScaleEffect.to(
        Vector2.all(1.12),
        EffectController(duration: 0.12, reverseDuration: 0.12),
      ),
    );
  }
}
