import 'package:flame/components.dart';

import 'coin_badge_component.dart';
import 'level_badge_component.dart';
import 'lives_component.dart';

class GameplayHudComponent extends PositionComponent {
  GameplayHudComponent({required this.lives, required this.screenSize});

  final int lives;
  final Vector2 screenSize;
  late final LivesComponent livesComponent;

  @override
  Future<void> onLoad() async {
    add(LevelBadgeComponent(position: Vector2(16, 18)));
    livesComponent = LivesComponent(
      lives: lives,
      position: Vector2(screenSize.x / 2 - 40, 24),
    );
    add(livesComponent);
    add(CoinBadgeComponent(position: Vector2(screenSize.x - 16, 18)));
  }

  void refreshLives(int lives) {
    livesComponent.refresh(lives);
  }
}
