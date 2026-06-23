import 'package:flame/game.dart';

import '../game_core/game_core.dart';
import 'bootstrap/game_asset_loader.dart';
import 'bootstrap/prototype_level.dart';
import 'components/arrows/arrow_tile_component.dart';
import 'components/background/garden_background_component.dart';
import 'components/board/board_grid_component.dart';
import 'components/debug/visual_debug_overlay_component.dart';
import 'components/effects/blocked_path_effect_component.dart';
import 'components/effects/gate_burst_component.dart';
import 'components/effects/wrong_tap_effect_component.dart';
import 'components/gates/gate_lane_component.dart';
import 'components/hud/gameplay_hud_component.dart';
import 'config/prototype_gameplay_config.dart';
import 'controllers/gameplay_controller.dart';
import 'layout/board_layout_calculator.dart';
import 'layout/gameplay_layout.dart';
import 'mapping/core_to_flame_mapper.dart';

class ArrowGateGame extends FlameGame {
  ArrowGateGame({
    required this.initialBundle,
    GameAssetLoader? assetLoader,
    GameplayController? controller,
    this.config = const PrototypeGameplayConfig(),
    this.debugLevel = false,
  }) : assetLoader = assetLoader ?? GameAssetLoader(),
       controller =
           controller ??
           GameplayController(initialState: initialBundle.gameState);

  final PrototypeLevelBundle initialBundle;
  final GameAssetLoader assetLoader;
  final GameplayController controller;
  final PrototypeGameplayConfig config;
  final bool debugLevel;

  late GameplayLayout layout;
  late CoreToFlameMapper mapper;
  late GameplayHudComponent hud;
  final arrowComponents = <String, ArrowTileComponent>{};
  final gateLaneComponents = <GateEdge, GateLaneComponent>{};
  double gateCountdown = 0;
  bool isGameplayReady = false;

  int get activeArrowCount => controller.state.board.arrows.values
      .where((arrow) => !arrow.exited)
      .length;

  @override
  Future<void> onLoad() async {
    await GameAssetLoader(
      images: images,
      arrowResolver: assetLoader.arrowResolver,
      gateResolver: assetLoader.gateResolver,
    ).preload();
    layout = const BoardLayoutCalculator().calculate(
      screenSize: size,
      gridSize: controller.state.board.rows,
    );
    mapper = CoreToFlameMapper(layout);
    await add(GardenBackgroundComponent()..priority = 0);
    await add(
      BoardGridComponent(board: controller.state.board, layout: layout)
        ..priority = 10,
    );
    await _addArrows();
    await _addGates();
    hud = GameplayHudComponent(lives: controller.state.lives, screenSize: size)
      ..priority = 50;
    await add(hud);
    if (debugLevel) {
      await _refreshDebug();
    }
    gateCountdown = config.gateInterval.inMilliseconds / 1000;
    isGameplayReady = true;
  }

  Future<void> _addArrows() async {
    for (final arrow in controller.state.board.arrows.values) {
      if (arrow.exited) {
        continue;
      }
      final component = ArrowTileComponent(
        arrow: arrow,
        position: mapper.cellCenter(arrow.position),
        cellSize: layout.cellSize,
      )..priority = 20;
      arrowComponents[arrow.id] = component;
      await add(component);
    }
  }

  Future<void> _addGates() async {
    for (final lane in controller.state.lanes.values) {
      final component = GateLaneComponent(lane: lane, layout: layout)
        ..priority = 30;
      gateLaneComponents[lane.edge] = component;
      await add(component);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameplayReady || controller.state.phase != GamePhase.ready) {
      return;
    }
    gateCountdown -= dt;
    if (gateCountdown <= 0) {
      rotateGates();
      gateCountdown = config.gateInterval.inMilliseconds / 1000;
    }
  }

  void rotateGates() {
    controller.rotateGates();
    for (final entry in controller.state.lanes.entries) {
      gateLaneComponents[entry.key]?.refresh(entry.value);
    }
    _refreshDebug();
  }

  void handleArrowTap(String arrowId) {
    if (!isGameplayReady || controller.inputLocked) {
      return;
    }
    final result = controller.handleArrowTap(
      arrowId,
      DateTime.now().millisecondsSinceEpoch,
    );
    final component = arrowComponents[arrowId];
    switch (result.type) {
      case TapResultType.validExit:
        final target = mapper.gateSlotCenter(
          result.debug.expectedEdge!,
          result.debug.expectedSlotIndex!,
        );
        component?.launchTo(target, () {
          component.removeFromParent();
          arrowComponents.remove(arrowId);
          add(
            GateBurstComponent(position: target, size: layout.cellSize * 1.5)
              ..priority = 40,
          );
          controller.commitValidExit(arrowId);
          hud.refreshLives(controller.state.lives);
          if (controller.isComplete) {
            overlays.add('complete');
          }
          _refreshDebug();
        });
      case TapResultType.pathBlocked:
        component?.shake();
        final block = result.debug.blockingPosition;
        if (block != null) {
          add(
            BlockedPathEffectComponent(
              position: mapper.cellCenter(block),
              size: Vector2.all(layout.cellSize),
            )..priority = 40,
          );
        }
        _afterInvalid();
      case TapResultType.wrongGateColor:
      case TapResultType.noGateAligned:
      case TapResultType.gateLocked:
      case TapResultType.tapTooEarly:
      case TapResultType.tapTooLate:
        component?.shake();
        final edge = result.debug.expectedEdge;
        final slot = result.debug.expectedSlotIndex;
        if (edge != null && slot != null) {
          add(
            WrongTapEffectComponent(
              position: mapper.gateSlotCenter(edge, slot),
              size: layout.cellSize,
            )..priority = 40,
          );
        }
        _afterInvalid();
      case TapResultType.invalidGamePhase:
      case TapResultType.tapBuffered:
      case TapResultType.arrowNotFound:
        controller.inputController.unlock();
    }
  }

  void _afterInvalid() {
    hud.refreshLives(controller.state.lives);
    if (controller.isFailed) {
      overlays.add('failed');
    }
    _refreshDebug();
  }

  void pausePrototype() {
    pauseEngine();
    controller.pause();
    overlays.add('pause');
  }

  void resumePrototype() {
    overlays.remove('pause');
    controller.resume();
    resumeEngine();
  }

  Future<void> restartPrototype() async {
    overlays
      ..remove('pause')
      ..remove('complete')
      ..remove('failed');
    removeAll(children.toList());
    arrowComponents.clear();
    gateLaneComponents.clear();
    controller.restart(initialBundle.gameState);
    isGameplayReady = false;
    await onLoad();
    resumeEngine();
  }

  Future<void> _refreshDebug() async {
    if (!debugLevel || !isGameplayReady) {
      return;
    }
    children.whereType<VisualDebugOverlayComponent>().forEach((component) {
      component.removeFromParent();
    });
    await add(
      VisualDebugOverlayComponent(
        phase: controller.state.phase,
        lives: controller.state.lives,
        activeArrows: activeArrowCount,
        gateTick: controller.gateController.tick,
        inputLocked: controller.inputLocked,
        lastResult: controller.lastResult?.type,
      )..priority = 100,
    );
  }
}
