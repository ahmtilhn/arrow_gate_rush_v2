import 'package:flame/components.dart';

import 'gameplay_layout.dart';
import 'gameplay_safe_area.dart';

class BoardLayoutCalculator {
  const BoardLayoutCalculator();

  GameplayLayout calculate({
    required Vector2 screenSize,
    required int gridSize,
    GameplaySafeArea safeArea = const GameplaySafeArea(),
  }) {
    final usableWidth = screenSize.x - safeArea.left - safeArea.right;
    final usableHeight = screenSize.y - safeArea.top - safeArea.bottom;
    final topHud = (usableHeight * 0.14).clamp(72.0, 128.0);
    final bottom = (usableHeight * 0.14).clamp(72.0, 120.0);
    final gateGap = (usableWidth * 0.012).clamp(4.0, 8.0);
    final maxByWidth = usableWidth - 32 - (2 * (gateGap + 34));
    final maxByHeight = usableHeight - topHud - bottom - (2 * (gateGap + 34));
    final boardSize = maxByWidth < maxByHeight ? maxByWidth : maxByHeight;
    final clampedBoard = boardSize.clamp(220.0, usableWidth - 24);
    final cellSize = clampedBoard / gridSize;
    final topLeft = Vector2(
      safeArea.left + (usableWidth - clampedBoard) / 2,
      safeArea.top +
          topHud +
          (usableHeight - topHud - bottom - clampedBoard) / 2,
    );
    return GameplayLayout(
      size: screenSize,
      gridSize: gridSize,
      boardTopLeft: topLeft,
      boardSize: clampedBoard.toDouble(),
      cellSize: cellSize,
      gateGap: gateGap,
      topHudHeight: topHud,
      bottomControlsHeight: bottom,
    );
  }
}
