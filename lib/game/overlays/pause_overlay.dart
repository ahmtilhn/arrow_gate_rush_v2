import 'package:flutter/material.dart';

import '../arrow_gate_game.dart';
import '../prototype_strings.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({required this.game, super.key});

  final ArrowGateGame game;

  @override
  Widget build(BuildContext context) {
    const strings = PrototypeStrings();
    return _PrototypePanel(
      children: [
        Text(strings.paused, style: Theme.of(context).textTheme.headlineSmall),
        ElevatedButton(
          onPressed: game.resumePrototype,
          child: Text(strings.resume),
        ),
        ElevatedButton(
          onPressed: game.restartPrototype,
          child: Text(strings.restart),
        ),
      ],
    );
  }
}

class _PrototypePanel extends StatelessWidget {
  const _PrototypePanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x88000000),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE9D8B8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }
}
