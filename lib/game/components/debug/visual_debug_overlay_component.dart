import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../../game_core/game_core.dart';

class VisualDebugOverlayComponent extends TextComponent {
  VisualDebugOverlayComponent({
    required this.phase,
    required this.lives,
    required this.activeArrows,
    required this.gateTick,
    required this.inputLocked,
    this.lastResult,
  }) : super(
         textRenderer: TextPaint(
           style: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
         ),
         position: Vector2(12, 86),
       );

  final GamePhase phase;
  final int lives;
  final int activeArrows;
  final int gateTick;
  final bool inputLocked;
  final TapResultType? lastResult;

  @override
  Future<void> onLoad() async {
    if (!kDebugMode) {
      removeFromParent();
      return;
    }
    text =
        'phase=$phase tick=$gateTick arrows=$activeArrows lives=$lives last=$lastResult locked=$inputLocked';
  }
}
