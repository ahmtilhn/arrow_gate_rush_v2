import 'package:flutter/foundation.dart';

enum Phase2QaMode {
  normal,
  loading,
  prototypeGameplay,
  validAlignment,
  blockedPath,
  wrongColorGate,
  noGateAligned,
  lockedGate,
  gateRotating,
  bufferedTap,
  pauseOverlay,
  levelComplete,
  levelFailed,
  visualDebugLevel,
}

extension Phase2QaModeX on Phase2QaMode {
  static Phase2QaMode parse(String? raw) {
    if (!kDebugMode || raw == null || raw.trim().isEmpty) {
      return Phase2QaMode.normal;
    }
    final normalized = raw.trim().toLowerCase();
    for (final value in Phase2QaMode.values) {
      if (value.name.toLowerCase() == normalized) {
        return value;
      }
    }
    return Phase2QaMode.normal;
  }

  String get captureFileName => switch (this) {
    Phase2QaMode.loading => '01_loading.png',
    Phase2QaMode.prototypeGameplay => '02_prototype_gameplay.png',
    Phase2QaMode.validAlignment => '03_valid_alignment.png',
    Phase2QaMode.blockedPath => '04_blocked_path.png',
    Phase2QaMode.wrongColorGate => '05_wrong_color_gate.png',
    Phase2QaMode.noGateAligned => '06_no_gate_aligned.png',
    Phase2QaMode.lockedGate => '07_locked_gate.png',
    Phase2QaMode.gateRotating => '08_gate_rotating.png',
    Phase2QaMode.bufferedTap => '09_buffered_tap.png',
    Phase2QaMode.pauseOverlay => '10_pause_overlay.png',
    Phase2QaMode.levelComplete => '11_level_complete.png',
    Phase2QaMode.levelFailed => '12_level_failed.png',
    Phase2QaMode.visualDebugLevel => '13_visual_debug_level.png',
    Phase2QaMode.normal => '',
  };
}
