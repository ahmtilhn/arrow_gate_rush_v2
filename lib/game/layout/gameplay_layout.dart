import 'package:flame/components.dart';

class GameplayLayout {
  const GameplayLayout({
    required this.size,
    required this.gridSize,
    required this.boardTopLeft,
    required this.boardSize,
    required this.cellSize,
    required this.gateGap,
    required this.topHudHeight,
    required this.bottomControlsHeight,
  });

  final Vector2 size;
  final int gridSize;
  final Vector2 boardTopLeft;
  final double boardSize;
  final double cellSize;
  final double gateGap;
  final double topHudHeight;
  final double bottomControlsHeight;
}
