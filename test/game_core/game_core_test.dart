import 'package:arrow_gate_rush_v2/game_core/game_core.dart';
import 'package:flutter_test/flutter_test.dart';

const timing = GameplayTimingConfig();
const buffer = TapBufferSystem(timing);
const moveValidator = MoveValidator();
const rotationSystem = GateRotationSystem();
const reducer = GameStateReducer();

void main() {
  group('move validation', () {
    for (final direction in ArrowDirection.values) {
      test('valid exit for $direction', () {
        final state = fixtureFor(
          direction: direction,
          color: ArrowColor.green,
          gateColor: ArrowColor.green,
        );
        final result = validate(state);
        expect(result.type, TapResultType.validExit);
        expect(result.debug.expectedEdge, direction.destinationEdge);
        expect(result.debug.expectedSlotIndex, expectedSlot(direction));
      });
    }

    for (final color in ArrowColor.values) {
      test('valid exit for color $color', () {
        final state = fixtureFor(color: color, gateColor: color);
        expect(validate(state).type, TapResultType.validExit);
      });
    }

    for (final size in [5, 6, 7, 8]) {
      test('coordinate handling for ${size}x$size', () {
        final state = fixtureFor(size: size, arrowPosition: GridPosition(2, 2));
        final result = validate(state);
        expect(result.type, TapResultType.validExit);
        expect(result.debug.expectedSlotIndex, 2);
      });
    }

    test('wrong color aligned gate is rejected', () {
      final state = fixtureFor(gateColor: ArrowColor.red);
      expect(validate(state).type, TapResultType.wrongGateColor);
    });

    test('empty aligned gate slot is rejected', () {
      final state = fixtureFor(gateAtExpectedSlot: false);
      expect(validate(state).type, TapResultType.noGateAligned);
    });

    test('locked aligned gate is rejected', () {
      final state = fixtureFor(gateLocked: true);
      expect(validate(state).type, TapResultType.gateLocked);
    });

    test('closed aligned gate is treated as locked/unavailable', () {
      final state = fixtureFor(gateOpen: false);
      expect(validate(state).type, TapResultType.gateLocked);
    });

    test('blocked path is rejected before matching gate permits exit', () {
      final state = fixtureFor(
        blockers: {const GridPosition(2, 3): const BoardCell.obstacle()},
      );
      final result = validate(state);
      expect(result.type, TapResultType.pathBlocked);
      expect(result.debug.blockingPosition, const GridPosition(2, 3));
    });

    test('invalid game phase is rejected', () {
      final state = fixtureFor(phase: GamePhase.arrowLaunching);
      expect(validate(state).type, TapResultType.invalidGamePhase);
    });

    test('missing arrow ID is rejected', () {
      final state = fixtureFor();
      final result = moveValidator.validate(
        state: state,
        attempt: const TapAttempt(arrowId: 'missing', timestampMs: 0),
        timingDecision: const TapTimingDecision(
          type: TapTimingDecisionType.acceptPreviousCommitted,
        ),
      );
      expect(result.type, TapResultType.arrowNotFound);
    });

    test('different row or column gate is not aligned', () {
      final state = fixtureFor(gateAtExpectedSlot: false, offSlotGate: true);
      expect(validate(state).type, TapResultType.noGateAligned);
    });
  });

  group('path validation', () {
    const pathValidator = PathValidator();

    for (final direction in ArrowDirection.values) {
      test('empty route for $direction', () {
        final state = fixtureFor(direction: direction);
        final arrow = state.board.arrows['a1']!;
        final result = pathValidator.validate(
          board: state.board,
          arrowId: arrow.id,
          from: arrow.position,
          direction: arrow.direction,
        );
        expect(result.isClear, isTrue);
      });

      test('edge-position arrow for $direction has empty route', () {
        final position = switch (direction) {
          ArrowDirection.up => const GridPosition(0, 2),
          ArrowDirection.down => const GridPosition(4, 2),
          ArrowDirection.left => const GridPosition(2, 0),
          ArrowDirection.right => const GridPosition(2, 4),
        };
        final state = fixtureFor(direction: direction, arrowPosition: position);
        final arrow = state.board.arrows['a1']!;
        final result = pathValidator.validate(
          board: state.board,
          arrowId: arrow.id,
          from: arrow.position,
          direction: arrow.direction,
        );
        expect(result.isClear, isTrue);
      });

      for (final distance in [1, 2]) {
        test('blocker at distance $distance for $direction', () {
          final blocker = positionAtDistance(
            const GridPosition(2, 2),
            direction,
            distance,
          );
          final state = fixtureFor(
            direction: direction,
            blockers: {blocker: const BoardCell.obstacle()},
          );
          final arrow = state.board.arrows['a1']!;
          final result = pathValidator.validate(
            board: state.board,
            arrowId: arrow.id,
            from: arrow.position,
            direction: arrow.direction,
          );
          expect(result.blockingPosition, blocker);
        });
      }
    }

    test('multiple blockers returns nearest blocker', () {
      final state = fixtureFor(
        blockers: {
          const GridPosition(2, 3): const BoardCell.obstacle(),
          const GridPosition(2, 4): const BoardCell.lockedTile(),
        },
      );
      expect(validate(state).debug.blockingPosition, const GridPosition(2, 3));
    });

    test('locked board tile blocks route', () {
      final state = fixtureFor(
        blockers: {const GridPosition(2, 3): const BoardCell.lockedTile()},
      );
      expect(validate(state).type, TapResultType.pathBlocked);
    });

    test('another arrow blocks route', () {
      final state = fixtureFor(
        extraArrows: {
          'a2': const ArrowTile(
            id: 'a2',
            position: GridPosition(2, 3),
            color: ArrowColor.blue,
            direction: ArrowDirection.up,
          ),
        },
      );
      expect(validate(state).type, TapResultType.pathBlocked);
    });

    test('non-blocking empty cell does not block route', () {
      final state = fixtureFor(
        blockers: {const GridPosition(2, 3): const BoardCell.empty()},
      );
      expect(validate(state).type, TapResultType.validExit);
    });
  });

  group('gate rotation', () {
    test('rotate once clockwise', () {
      final lane = laneWithIds(['a', null, 'b']);
      final rotated = rotationSystem.rotateOnce(lane);
      expect(slotIds(rotated), ['b', 'a', null]);
      expect(rotated.phase, 1);
    });

    test('wraparound clockwise', () {
      final lane = laneWithIds(['a', 'b', null]);
      expect(slotIds(rotationSystem.rotateOnce(lane)), [null, 'a', 'b']);
    });

    test('rotate N times', () {
      final lane = laneWithIds(['a', 'b', 'c', null]);
      expect(slotIds(rotationSystem.rotateBy(lane, 2)), ['c', null, 'a', 'b']);
    });

    test('independent lanes keep different phases', () {
      final top = laneWithIds(['t', null], edge: GateEdge.top);
      final right = laneWithIds(
        ['r', null],
        edge: GateEdge.right,
        direction: GateRotationDirection.counterclockwise,
      );
      expect(rotationSystem.rotateBy(top, 1).phase, 1);
      expect(rotationSystem.rotateBy(right, 3).phase, 3);
      expect(slotIds(rotationSystem.rotateBy(top, 1)), [null, 't']);
      expect(slotIds(rotationSystem.rotateBy(right, 1)), [null, 'r']);
    });

    test('counterclockwise order', () {
      final lane = laneWithIds([
        'a',
        null,
        'b',
      ], direction: GateRotationDirection.counterclockwise);
      expect(slotIds(rotationSystem.rotateOnce(lane)), [null, 'b', 'a']);
    });

    test('deterministic equality for same input', () {
      final lane = laneWithIds(['a', null, 'b', 'c']);
      expect(
        slotIds(rotationSystem.laneAtTick(lane, 7)),
        slotIds(rotationSystem.laneAtTick(lane, 7)),
      );
    });
  });

  group('tap buffer', () {
    const moving = GateTimingSnapshot(
      state: GateTimingState.visuallyMoving,
      rotationStartMs: 1000,
      commitMs: 1300,
    );
    const committed = GateTimingSnapshot(
      state: GateTimingState.rotationCommitted,
      rotationStartMs: 1000,
      commitMs: 1300,
    );

    test('exact lower boundary buffers', () {
      expect(
        buffer.evaluate(timing: moving, tapTimestampMs: 1150).type,
        TapTimingDecisionType.bufferForCommit,
      );
    });

    test('one millisecond before lower boundary is too early', () {
      expect(
        buffer.evaluate(timing: moving, tapTimestampMs: 1149).type,
        TapTimingDecisionType.tooEarly,
      );
    });

    test('exact upper pre-commit boundary buffers', () {
      expect(
        buffer.evaluate(timing: moving, tapTimestampMs: 1300).type,
        TapTimingDecisionType.bufferForCommit,
      );
    });

    test('new alignment accepts at commit', () {
      expect(
        buffer.evaluate(timing: committed, tapTimestampMs: 1300).type,
        TapTimingDecisionType.acceptNewCommitted,
      );
    });

    test('exact post-commit upper boundary accepts new alignment', () {
      expect(
        buffer.evaluate(timing: committed, tapTimestampMs: 1450).type,
        TapTimingDecisionType.acceptNewCommitted,
      );
    });

    test('one millisecond after post-commit boundary is too late', () {
      expect(
        buffer.evaluate(timing: committed, tapTimestampMs: 1451).type,
        TapTimingDecisionType.tooLate,
      );
    });

    test('stable accepts previous committed alignment', () {
      expect(
        buffer
            .evaluate(
              timing: const GateTimingSnapshot.stable(),
              tapTimestampMs: 9999,
            )
            .type,
        TapTimingDecisionType.acceptPreviousCommitted,
      );
    });

    test('rejected stale tap', () {
      expect(
        buffer
            .evaluate(
              timing: const GateTimingSnapshot(
                state: GateTimingState.postCommitBufferEnded,
                rotationStartMs: 1000,
                commitMs: 1300,
              ),
              tapTimestampMs: 2000,
            )
            .type,
        TapTimingDecisionType.tooLate,
      );
    });
  });

  group('state reducer', () {
    test('valid move state sequence', () {
      final state = fixtureFor();
      final evaluating = reducer.beginTapEvaluation(state);
      expect(evaluating.phase, GamePhase.evaluatingTap);
      final launching = reducer.applyTapResult(
        evaluating.copyWith(phase: GamePhase.ready),
        validate(state),
      );
      expect(launching.phase, GamePhase.arrowLaunching);
      final resolved = reducer.resolveValidMove(launching, 'a1');
      expect(resolved.phase, GamePhase.levelComplete);
    });

    test('invalid move sequence reduces life and returns ready', () {
      final state = fixtureFor(gateColor: ArrowColor.red, requiredIds: {});
      final result = validate(state);
      final next = reducer.applyTapResult(state, result);
      expect(next.lives, 2);
      expect(next.phase, GamePhase.ready);
    });

    test('pause and resume', () {
      final state = fixtureFor();
      expect(reducer.pause(state).phase, GamePhase.paused);
      expect(reducer.resume(reducer.pause(state)).phase, GamePhase.ready);
    });

    test('background and foreground', () {
      final state = fixtureFor();
      expect(reducer.background(state).phase, GamePhase.backgrounded);
      expect(
        reducer.foreground(reducer.background(state)).phase,
        GamePhase.ready,
      );
    });

    test('final move completion waits for committed removal', () {
      final state = fixtureFor();
      final launching = reducer.applyTapResult(state, validate(state));
      expect(launching.phase, GamePhase.arrowLaunching);
      expect(launching.board.arrows['a1']!.exited, isFalse);
      final complete = reducer.resolveValidMove(launching, 'a1');
      expect(complete.phase, GamePhase.levelComplete);
      expect(complete.board.arrows['a1']!.exited, isTrue);
    });

    test('life-zero failure', () {
      final state = fixtureFor(gateColor: ArrowColor.red, lives: 1);
      final failed = reducer.applyTapResult(state, validate(state));
      expect(failed.phase, GamePhase.levelFailed);
    });

    test('hard-mode invalid tap failure', () {
      final state = fixtureFor(
        gateColor: ArrowColor.red,
        hardModeInvalidTapFails: true,
      );
      final failed = reducer.applyTapResult(state, validate(state));
      expect(failed.phase, GamePhase.levelFailed);
    });

    test('no simultaneous completion and failure', () {
      final state = fixtureFor(lives: 1);
      final launching = reducer.applyTapResult(state, validate(state));
      final complete = reducer.resolveValidMove(launching, 'a1');
      expect(complete.phase, GamePhase.levelComplete);
      expect(complete.phase == GamePhase.levelFailed, isFalse);
    });
  });

  group('micro fixtures', () {
    test('matching aligned green right gate', () {
      expect(validate(fixtureOne()).type, TapResultType.validExit);
    });

    test('wrong-color aligned gate fixture', () {
      expect(validate(fixtureWrongColor()).type, TapResultType.wrongGateColor);
    });

    test('no aligned gate fixture', () {
      expect(validate(fixtureNoGate()).type, TapResultType.noGateAligned);
    });

    test('blocked path fixture', () {
      expect(validate(fixtureBlocked()).type, TapResultType.pathBlocked);
    });

    test('locked gate fixture', () {
      expect(validate(fixtureLocked()).type, TapResultType.gateLocked);
    });

    test('four-arrow dependency fixture starts blocked', () {
      expect(
        validate(fixtureFourArrowDependency()).type,
        TapResultType.pathBlocked,
      );
    });

    test('independent gate lanes fixture has different phases', () {
      final state = fixtureIndependentLanes();
      expect(
        state.lanes[GateEdge.top]!.phase,
        isNot(state.lanes[GateEdge.right]!.phase),
      );
    });

    test('final-move completion fixture completes', () {
      final state = fixtureFinalMoveCompletion();
      final complete = reducer.resolveValidMove(
        reducer.applyTapResult(state, validate(state)),
        'a1',
      );
      expect(complete.phase, GamePhase.levelComplete);
    });

    test('life-zero failure fixture fails', () {
      final state = fixtureLifeZeroFailure();
      expect(
        reducer.applyTapResult(state, validate(state)).phase,
        GamePhase.levelFailed,
      );
    });

    test('tap-buffer boundary fixture buffers', () {
      expect(
        buffer
            .evaluate(timing: fixtureTapBufferBoundary(), tapTimestampMs: 1150)
            .type,
        TapTimingDecisionType.bufferForCommit,
      );
    });
  });

  group('property smoke', () {
    test('seeded rotations and validation stay deterministic', () {
      var seed = 42;
      for (var i = 0; i < 250; i += 1) {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        final size = 5 + (seed % 4);
        final row = 1 + (seed % (size - 2));
        final column = 1 + ((seed ~/ 7) % (size - 2));
        final direction =
            ArrowDirection.values[seed % ArrowDirection.values.length];
        final color = ArrowColor.values[(seed ~/ 3) % ArrowColor.values.length];
        final state = fixtureFor(
          size: size,
          arrowPosition: GridPosition(row, column),
          direction: direction,
          color: color,
          gateColor: color,
        );
        final before = state.board.arrows['a1']!.exited;
        final resultA = validate(state);
        final resultB = validate(state);
        expect(resultA.type, resultB.type);
        expect(state.board.arrows['a1']!.exited, before);

        final lane = state.lanes[direction.destinationEdge]!;
        final rotated = rotationSystem.rotateBy(lane, seed % 20);
        expect(rotated.slots.length, lane.slots.length);
        expect(
          rotated.slots.whereType<GateSlot>().map((slot) => slot.id).toSet(),
          lane.slots.whereType<GateSlot>().map((slot) => slot.id).toSet(),
        );
        expect(resultA.debug.expectedSlotIndex! >= 0, isTrue);
        expect(resultA.debug.expectedSlotIndex! < size, isTrue);
      }
    });
  });
}

TapResult validate(GameState state) {
  return moveValidator.validate(
    state: state,
    attempt: const TapAttempt(arrowId: 'a1', timestampMs: 0),
    timingDecision: const TapTimingDecision(
      type: TapTimingDecisionType.acceptPreviousCommitted,
    ),
  );
}

GameState fixtureFor({
  int size = 5,
  GridPosition arrowPosition = const GridPosition(2, 2),
  ArrowDirection direction = ArrowDirection.right,
  ArrowColor color = ArrowColor.green,
  ArrowColor gateColor = ArrowColor.green,
  bool gateAtExpectedSlot = true,
  bool offSlotGate = false,
  bool gateLocked = false,
  bool gateOpen = true,
  GamePhase phase = GamePhase.ready,
  Map<GridPosition, BoardCell> blockers = const {},
  Map<String, ArrowTile> extraArrows = const {},
  Set<String>? requiredIds,
  int lives = 3,
  bool hardModeInvalidTapFails = false,
}) {
  final arrow = ArrowTile(
    id: 'a1',
    position: arrowPosition,
    color: color,
    direction: direction,
  );
  final arrows = <String, ArrowTile>{'a1': arrow, ...extraArrows};
  final expected = expectedSlot(direction, arrowPosition);
  final lanes = <GateEdge, GateLane>{};
  for (final edge in GateEdge.values) {
    final slots = List<GateSlot?>.filled(size, null);
    if (edge == direction.destinationEdge && gateAtExpectedSlot) {
      slots[expected] = GateSlot(
        id: 'g1',
        color: gateColor,
        isLocked: gateLocked,
        isOpen: gateOpen,
      );
    }
    if (edge == direction.destinationEdge && offSlotGate) {
      slots[(expected + 1) % size] = GateSlot(id: 'off', color: gateColor);
    }
    lanes[edge] = GateLane(edge: edge, slots: slots);
  }
  return GameState(
    board: BoardState(
      rows: size,
      columns: size,
      arrows: arrows,
      cells: blockers,
    ),
    lanes: lanes,
    phase: phase,
    lives: lives,
    level: LevelDefinition(
      id: 'fixture',
      requiredArrowIds: requiredIds ?? {'a1'},
      hardModeInvalidTapFails: hardModeInvalidTapFails,
    ),
  );
}

int expectedSlot(
  ArrowDirection direction, [
  GridPosition position = const GridPosition(2, 2),
]) {
  return switch (direction.destinationEdge) {
    GateEdge.top || GateEdge.bottom => position.column,
    GateEdge.left || GateEdge.right => position.row,
  };
}

GridPosition positionAtDistance(
  GridPosition from,
  ArrowDirection direction,
  int distance,
) {
  return switch (direction) {
    ArrowDirection.up => GridPosition(from.row - distance, from.column),
    ArrowDirection.down => GridPosition(from.row + distance, from.column),
    ArrowDirection.left => GridPosition(from.row, from.column - distance),
    ArrowDirection.right => GridPosition(from.row, from.column + distance),
  };
}

GateLane laneWithIds(
  List<String?> ids, {
  GateEdge edge = GateEdge.top,
  GateRotationDirection direction = GateRotationDirection.clockwise,
}) {
  return GateLane(
    edge: edge,
    rotationDirection: direction,
    slots: [
      for (final id in ids)
        id == null ? null : GateSlot(id: id, color: ArrowColor.green),
    ],
  );
}

List<String?> slotIds(GateLane lane) {
  return [for (final slot in lane.slots) slot?.id];
}

GameState fixtureOne() => fixtureFor();

GameState fixtureWrongColor() => fixtureFor(gateColor: ArrowColor.red);

GameState fixtureNoGate() => fixtureFor(gateAtExpectedSlot: false);

GameState fixtureBlocked() {
  return fixtureFor(
    blockers: {const GridPosition(2, 3): const BoardCell.obstacle()},
  );
}

GameState fixtureLocked() => fixtureFor(gateLocked: true);

GameState fixtureFourArrowDependency() {
  return fixtureFor(
    extraArrows: {
      'a2': const ArrowTile(
        id: 'a2',
        position: GridPosition(2, 3),
        color: ArrowColor.green,
        direction: ArrowDirection.right,
      ),
      'a3': const ArrowTile(
        id: 'a3',
        position: GridPosition(1, 3),
        color: ArrowColor.blue,
        direction: ArrowDirection.up,
      ),
      'a4': const ArrowTile(
        id: 'a4',
        position: GridPosition(3, 3),
        color: ArrowColor.red,
        direction: ArrowDirection.down,
      ),
    },
    requiredIds: {'a1', 'a2', 'a3', 'a4'},
  );
}

GameState fixtureIndependentLanes() {
  final state = fixtureFor();
  final lanes = Map<GateEdge, GateLane>.from(state.lanes);
  lanes[GateEdge.top] = lanes[GateEdge.top]!.copyWith(phase: 2);
  lanes[GateEdge.right] = lanes[GateEdge.right]!.copyWith(phase: 5);
  return state.copyWith(lanes: lanes);
}

GameState fixtureFinalMoveCompletion() => fixtureFor(requiredIds: {'a1'});

GameState fixtureLifeZeroFailure() =>
    fixtureFor(gateColor: ArrowColor.red, lives: 1);

GateTimingSnapshot fixtureTapBufferBoundary() {
  return const GateTimingSnapshot(
    state: GateTimingState.visuallyMoving,
    rotationStartMs: 1000,
    commitMs: 1300,
  );
}
