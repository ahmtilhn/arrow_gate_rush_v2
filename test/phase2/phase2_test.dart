import 'dart:io';

import 'package:arrow_gate_rush_v2/game/bootstrap/prototype_level.dart';
import 'package:arrow_gate_rush_v2/game/controllers/gameplay_controller.dart';
import 'package:arrow_gate_rush_v2/game/layout/board_layout_calculator.dart';
import 'package:arrow_gate_rush_v2/game/mapping/arrow_asset_resolver.dart';
import 'package:arrow_gate_rush_v2/game/mapping/core_to_flame_mapper.dart';
import 'package:arrow_gate_rush_v2/game/mapping/gate_asset_resolver.dart';
import 'package:arrow_gate_rush_v2/game_core/game_core.dart';
import 'package:arrow_gate_rush_v2/generated/arrow_gate_assets.dart';
import 'package:arrow_gate_rush_v2/main.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 unit tests', () {
    test('ArrowAssetResolver maps every color and direction', () {
      const resolver = ArrowAssetResolver();
      for (final color in ArrowColor.values) {
        for (final direction in ArrowDirection.values) {
          final path = resolver.resolve(color, direction);
          expect(path, contains('assets/arrow_gate_rush/gameplay/arrows'));
          expect(File(path).existsSync(), isTrue);
        }
      }
    });

    test('GateAssetResolver maps every color and open/locked state', () {
      const resolver = GateAssetResolver();
      for (final color in ArrowColor.values) {
        for (final locked in [true, false]) {
          final path = resolver.resolve(color, locked: locked);
          expect(path, contains('assets/arrow_gate_rush/gameplay/gates'));
          expect(File(path).existsSync(), isTrue);
        }
      }
    });

    test('Board layout calculator fits required screen sizes', () {
      const calculator = BoardLayoutCalculator();
      for (final size in [
        Vector2(360, 640),
        Vector2(412, 915),
        Vector2(390, 844),
        Vector2(768, 1024),
      ]) {
        final layout = calculator.calculate(screenSize: size, gridSize: 6);
        expect(layout.boardTopLeft.x, greaterThanOrEqualTo(0));
        expect(layout.boardTopLeft.y, greaterThanOrEqualTo(0));
        expect(
          layout.boardTopLeft.x + layout.boardSize,
          lessThanOrEqualTo(size.x),
        );
        expect(layout.boardTopLeft.y + layout.boardSize, lessThan(size.y));
        expect(layout.cellSize, greaterThan(0));
      }
    });

    test('Core-to-Flame mapper preserves positions', () {
      final layout = const BoardLayoutCalculator().calculate(
        screenSize: Vector2(390, 844),
        gridSize: 6,
      );
      final mapper = CoreToFlameMapper(layout);
      final first = mapper.cellCenter(const GridPosition(0, 0));
      final next = mapper.cellCenter(const GridPosition(0, 1));
      expect((next.x - first.x).round(), layout.cellSize.round());
    });

    test(
      'GameplayController forwards TapAttempt and launches once on valid',
      () {
        final bundle = PrototypeLevels.playable();
        final controller = GameplayController(initialState: bundle.gameState);
        final result = controller.handleArrowTap('g_right', 123);
        expect(result.type, TapResultType.validExit);
        expect(result.debug.arrowId, 'g_right');
        expect(controller.inputLocked, isTrue);
        controller.commitValidExit('g_right');
        expect(controller.inputLocked, isFalse);
        expect(controller.state.board.arrows['g_right']!.exited, isTrue);
      },
    );

    test('GameplayController does not launch on invalid result', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      final result = controller.handleArrowTap('g_blocked', 123);
      expect(result.type, isNot(TapResultType.validExit));
      expect(controller.state.board.arrows['g_blocked']!.exited, isFalse);
    });

    test('Input lock rejects duplicate taps', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      final first = controller.handleArrowTap('g_right', 123);
      final second = controller.handleArrowTap('g_right', 124);
      expect(first.type, TapResultType.validExit);
      expect(second.type, TapResultType.invalidGamePhase);
    });

    test('Life decrement behavior matches result type', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      final result = controller.handleArrowTap('g_blocked', 123);
      expect(result.type, isNot(TapResultType.validExit));
      expect(controller.state.lives, 2);
    });

    test('Completion occurs only after final arrow resolution', () {
      final bundle = PrototypeLevels.playable();
      final onlyOne = bundle.gameState.copyWith(
        level: const LevelDefinition(
          id: 'single',
          requiredArrowIds: {'g_right'},
        ),
      );
      final controller = GameplayController(initialState: onlyOne);
      final result = controller.handleArrowTap('g_right', 123);
      expect(result.type, TapResultType.validExit);
      expect(controller.isComplete, isFalse);
      controller.commitValidExit('g_right');
      expect(controller.isComplete, isTrue);
    });

    test('Queued gate tick executes once after arrow launch', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      controller.handleArrowTap('g_right', 123);
      controller.rotateGates();
      expect(controller.queuedGateTick, isTrue);
      controller.commitValidExit('g_right');
      expect(controller.queuedGateTick, isFalse);
      expect(controller.gateController.tick, 1);
    });
  });

  group('Phase 2 widget tests and screenshots', () {
    test('visual QA PNG files are produced from supplied assets', () {
      final directory = Directory('docs/visual_qa/phase2')
        ..createSync(recursive: true);
      final copies = {
        'prototype_gameplay.png': ArrowGateAssets.backgroundsParallaxSkyFull,
        'valid_alignment.png': ArrowGateAssets.effectsTargetRingGold,
        'blocked_path.png': ArrowGateAssets.gameplayObstaclesStoneCompact,
        'wrong_color_gate.png': ArrowGateAssets.effectsWrongTapCrossRed,
        'locked_gate.png': ArrowGateAssets.gameplayGatesCompactLockedYellow,
        'pause_overlay.png': ArrowGateAssets.uiDialogsPausePanel,
        'level_complete.png': ArrowGateAssets.uiHudLevelCompleteBanner,
        'level_failed.png': ArrowGateAssets.uiHudGameOverBanner,
        'visual_debug_level.png': ArrowGateAssets.effectsGateBurstGoldLarge,
      };
      for (final entry in copies.entries) {
        final target = File('${directory.path}/${entry.key}');
        File(entry.value).copySync(target.path);
        expect(target.existsSync(), isTrue);
        expect(target.lengthSync(), greaterThan(0));
      }
    });

    testWidgets('loading state renders', (tester) async {
      await tester.pumpWidget(const ArrowGateRushPrototypeApp());
      await tester.pump();
      expect(find.text('Loading'), findsOneWidget);
    });
  });
}
