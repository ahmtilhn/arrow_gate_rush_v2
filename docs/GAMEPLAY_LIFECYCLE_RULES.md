# Phase 2 Gameplay Lifecycle Rules

Review date: 2026-06-23

## Boot

1. Flutter starts `ArrowGateRushPrototypeApp`.
2. `GameBootstrap` locks portrait orientation.
3. `GameHost` displays loading state.
4. `ArrowGateGame` preloads required supplied PNG textures.
5. Components are created only after preload.
6. Gameplay becomes ready after background, board, arrows, gates, and HUD are loaded.

## Pause

- `pausePrototype()` pauses the Flame engine and changes the core state to `paused`.
- Gate countdown stops because `update()` no longer advances.
- Arrow input is ignored while paused.
- No ad logic exists in Phase 2 pause.

## Resume

- `resumePrototype()` removes the pause overlay, restores core state to `ready`, and resumes the Flame engine.
- Existing gate lane state and current lives are retained.

## Background / Foreground

- Flutter lifecycle observer calls `pausePrototype()` on inactive/paused states.
- On resumed state, a paused prototype resumes.
- No logical gate ticks occur while paused/backgrounded.

## Restart

- `restartPrototype()` removes overlays, clears Flame children, restores the deterministic prototype level, resets queued gate ticks, and reloads components.

## Buffered Tap State

Phase 2 keeps tap-buffer rules in the Phase 1 `TapBufferSystem`. During a visual gate slide, buffered taps are modelled by deterministic timing decisions. No rendering frame decides logical alignment.
