import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../../../game_core/game_core.dart';
import '../../layout/gameplay_layout.dart';
import '../../mapping/core_to_flame_mapper.dart';
import 'gate_component.dart';

class GateLaneComponent extends PositionComponent {
  GateLaneComponent({required this.lane, required this.layout});

  GateLane lane;
  final GameplayLayout layout;

  @override
  Future<void> onLoad() async {
    refresh(lane);
  }

  void refresh(GateLane nextLane) {
    lane = nextLane;
    removeAll(children.toList());
    final mapper = CoreToFlameMapper(layout);
    for (var index = 0; index < lane.slots.length; index += 1) {
      final gate = lane.slots[index];
      if (gate != null) {
        add(
          GateComponent(
            gate: gate,
            edge: lane.edge,
            slotIndex: index,
            position: mapper.gateSlotCenter(lane.edge, index),
            cellSize: layout.cellSize * 0.92,
          ),
        );
      }
    }
  }

  Future<void> animateTo(GateLane nextLane, Duration duration) async {
    final mapper = CoreToFlameMapper(layout);
    final currentById = <String, GateComponent>{
      for (final component in children.whereType<GateComponent>())
        component.gate.id: component,
    };

    for (var index = 0; index < nextLane.slots.length; index += 1) {
      final gate = nextLane.slots[index];
      if (gate == null) {
        continue;
      }
      final target = mapper.gateSlotCenter(nextLane.edge, index);
      final existing = currentById[gate.id];
      if (existing == null) {
        add(
          GateComponent(
            gate: gate,
            edge: nextLane.edge,
            slotIndex: index,
            position: target,
            cellSize: layout.cellSize * 0.92,
          ),
        );
      } else {
        existing.add(
          MoveEffect.to(
            target,
            EffectController(duration: duration.inMilliseconds / 1000),
          ),
        );
      }
    }

    lane = nextLane;
    await Future<void>.delayed(duration);
  }
}
