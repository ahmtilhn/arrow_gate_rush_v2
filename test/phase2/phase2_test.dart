import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arrow_gate_rush_v2/game/bootstrap/prototype_level.dart';
import 'package:arrow_gate_rush_v2/game/controllers/gameplay_controller.dart';
import 'package:arrow_gate_rush_v2/game/layout/board_layout_calculator.dart';
import 'package:arrow_gate_rush_v2/game/mapping/arrow_asset_resolver.dart';
import 'package:arrow_gate_rush_v2/game/mapping/core_to_flame_mapper.dart';
import 'package:arrow_gate_rush_v2/game/mapping/gate_asset_resolver.dart';
import 'package:arrow_gate_rush_v2/game/qa/phase2_qa_mode.dart';
import 'package:arrow_gate_rush_v2/game/qa/runtime_capture_manifest.dart';
import 'package:arrow_gate_rush_v2/game_core/game_core.dart';
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

    test('Board layout calculator fits every acceptance profile', () {
      const calculator = BoardLayoutCalculator();
      for (final size in [
        Vector2(360, 640),
        Vector2(360, 800),
        Vector2(393, 852),
        Vector2(412, 915),
        Vector2(600, 960),
        Vector2(800, 1280),
      ]) {
        final layout = calculator.calculate(screenSize: size, gridSize: 6);
        expect(layout.boardTopLeft.x, greaterThanOrEqualTo(0));
        expect(layout.boardTopLeft.y, greaterThanOrEqualTo(0));
        expect(
          layout.boardTopLeft.x + layout.boardSize,
          lessThanOrEqualTo(size.x),
        );
        expect(
          layout.boardTopLeft.y + layout.boardSize,
          lessThan(size.y),
        );
        expect(layout.cellSize, greaterThan(0));
      }
    });

    test('Core-to-Flame mapper preserves positions', () {
      final layout = const BoardLayoutCalculator().calculate(
        screenSize: Vector2(393, 852),
        gridSize: 6,
      );
      final mapper = CoreToFlameMapper(layout);
      final first = mapper.cellCenter(const GridPosition(0, 0));
      final next = mapper.cellCenter(const GridPosition(0, 1));
      expect((next.x - first.x).round(), layout.cellSize.round());
    });

    test('GameplayController launches once on a valid tap', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      final result = controller.handleArrowTap('g_right', 123);
      expect(result.type, TapResultType.validExit);
      expect(result.debug.arrowId, 'g_right');
      expect(controller.inputLocked, isTrue);
      controller.commitValidExit('g_right');
      expect(controller.inputLocked, isFalse);
      expect(controller.state.board.arrows['g_right']!.exited, isTrue);
    });

    test('GameplayController does not launch a blocked arrow', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      final result = controller.handleArrowTap('g_blocked', 123);
      expect(result.type, TapResultType.pathBlocked);
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

    test('Penalized result decrements a life', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      controller.handleArrowTap('g_blocked', 123);
      expect(controller.state.lives, 2);
    });

    test('Buffered timing is produced by the runtime controller path', () {
      final bundle = PrototypeLevels.playable();
      final controller = GameplayController(initialState: bundle.gameState);
      const moving = GateTimingSnapshot(
        state: GateTimingState.visuallyMoving,
        rotationStartMs: 1000,
        commitMs: 1300,
      );
      final result = controller.handleArrowTap(
        'g_right',
        1200,
        timing: moving,
      );
      expect(result.type, TapResultType.tapBuffered);
      expect(controller.state.lives, 3);
      expect(controller.inputLocked, isFalse);
    });

    test('Completion occurs only after final arrow resolution', () {
      final bundle = PrototypeLevels.forQaMode(Phase2QaMode.levelComplete);
      final controller = GameplayController(initialState: bundle.gameState);
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

    test('QA fixtures create the intended invalid causes', () {
      final wrong = GameplayController(
        initialState: PrototypeLevels.forQaMode(
          Phase2QaMode.wrongColorGate,
        ).gameState,
      ).handleArrowTap('g_right', 1);
      final empty = GameplayController(
        initialState: PrototypeLevels.forQaMode(
          Phase2QaMode.noGateAligned,
        ).gameState,
      ).handleArrowTap('g_right', 1);
      final locked = GameplayController(
        initialState: PrototypeLevels.forQaMode(
          Phase2QaMode.lockedGate,
        ).gameState,
      ).handleArrowTap('g_right', 1);
      expect(wrong.type, TapResultType.wrongGateColor);
      expect(empty.type, TapResultType.noGateAligned);
      expect(locked.type, TapResultType.gateLocked);
    });

    test('Prototype solution clears blocker before dependent arrows', () {
      final order = PrototypeLevels.playable().solutionOrder;
      expect(order.indexOf('g_right'), lessThan(order.indexOf('g_blocked')));
      expect(order.indexOf('g_blocked'), lessThan(order.indexOf('y_down')));
    });
  });

  group('Phase 2 asset integrity', () {
    test('catalog references 186 existing decodable PNG assets', () {
      final catalog = jsonDecode(
        File('config/asset_catalog.json').readAsStringSync(),
      ) as List<dynamic>;
      expect(catalog.length, 186);
      for (final raw in catalog) {
        final entry = raw as Map<String, dynamic>;
        final path = entry['path'] as String;
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: path);
        final bytes = file.readAsBytesSync();
        expect(bytes.length, greaterThan(25), reason: path);
        expect(
          bytes.sublist(0, 8),
          equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
          reason: path,
        );
        final data = ByteData.sublistView(Uint8List.fromList(bytes));
        expect(data.getUint32(16, Endian.big), greaterThan(0), reason: path);
        expect(data.getUint32(20, Endian.big), greaterThan(0), reason: path);
        if (entry['transparent_png'] == true) {
          expect(<int>{4, 6}, contains(bytes[25]), reason: path);
        }
      }
    });

    test('review modes are excluded when debug is disabled', () {
      expect(
        Phase2QaModeX.parse('blockedPath', debugEnabled: false),
        Phase2QaMode.normal,
      );
    });

    test('runtime capture filenames are unique and complete', () {
      final files = Phase2QaMode.values
          .where((mode) => mode != Phase2QaMode.normal)
          .map((mode) => mode.captureFileName)
          .toList();
      expect(files.length, 13);
      expect(files.toSet().length, files.length);
      expect(files.first, '01_loading.png');
      expect(files.last, '13_visual_debug_level.png');
    });

    test('runtime capture manifest schema accepts truthful entry', () {
      final entry = <String, Object?>{
        'filename': '02_prototype_gameplay.png',
        'captureMethod': 'adb shell screencap -p followed by adb pull',
        'platform': 'Android',
        'deviceModel': 'Android Emulator',
        'screenResolution': '1080x2400',
        'appPackageId': 'com.example.arrow_gate_rush_v2',
        'buildMode': 'debug',
        'captureTimestampUtc': '2026-06-24T00:00:00Z',
        'gameState': 'ready',
        'levelId': 'phase2_prototype',
        'expectedVisibleComponents': <String>['board'],
        'assetGeneratedPreview': false,
      };
      expect(RuntimeCaptureManifest.isValidEntry(entry), isTrue);
      expect(
        RuntimeCaptureManifest.isValidEntry({
          ...entry,
          'assetGeneratedPreview': true,
        }),
        isFalse,
      );
    });
  });

  group('Phase 2 widget tests', () {
    testWidgets('loading state renders before game is ready', (tester) async {
      await tester.pumpWidget(const ArrowGateRushPrototypeApp());
      await tester.pump();
      expect(find.text('Loading'), findsOneWidget);
    });
  });
}
