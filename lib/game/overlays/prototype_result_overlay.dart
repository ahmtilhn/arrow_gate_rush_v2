import 'package:flutter/material.dart';

import '../arrow_gate_game.dart';
import '../prototype_strings.dart';

class PrototypeResultOverlay extends StatelessWidget {
  const PrototypeResultOverlay({
    required this.game,
    required this.complete,
    super.key,
  });

  final ArrowGateGame game;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    const strings = PrototypeStrings();
    final title = complete ? strings.complete : strings.failed;
    return ColoredBox(
      color: const Color(0x99000000),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE9D8B8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton(
                  onPressed: game.restartPrototype,
                  child: Text(complete ? strings.restart : strings.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
