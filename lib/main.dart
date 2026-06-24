import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'game/arrow_gate_game.dart';
import 'game/bootstrap/game_bootstrap.dart';
import 'game/overlays/pause_overlay.dart';
import 'game/overlays/prototype_result_overlay.dart';
import 'game/prototype_strings.dart';
import 'game/qa/phase2_qa_mode.dart';
import 'generated/arrow_gate_assets.dart';

void main() {
  runApp(const ArrowGateRushPrototypeApp());
}

class ArrowGateRushPrototypeApp extends StatelessWidget {
  const ArrowGateRushPrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameHost(),
    );
  }
}

class GameHost extends StatefulWidget {
  const GameHost({super.key});

  @override
  State<GameHost> createState() => _GameHostState();
}

class _GameHostState extends State<GameHost> with WidgetsBindingObserver {
  static const _reviewMode = String.fromEnvironment('VISUAL_REVIEW_MODE');

  late final Phase2QaMode _selectedMode;
  Future<ArrowGateGame>? _gameFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedMode = kDebugMode
        ? Phase2QaModeX.parse(_reviewMode)
        : Phase2QaMode.normal;
    if (_selectedMode != Phase2QaMode.loading) {
      _gameFuture = const GameBootstrap().createGame(mode: _selectedMode);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _gameFuture?.then((game) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        game.pausePrototype();
      } else if (state == AppLifecycleState.resumed &&
          game.controller.state.phase.name == 'paused') {
        game.resumePrototype();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const strings = PrototypeStrings();
    if (_selectedMode == Phase2QaMode.loading) {
      return const _LoadingScreen(strings: strings);
    }
    return FutureBuilder<ArrowGateGame>(
      future: _gameFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _LoadingScreen(strings: strings);
        }
        final game = snapshot.data!;
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                GameWidget<ArrowGateGame>(
                  game: game,
                  overlayBuilderMap: {
                    'pause': (_, game) => PauseOverlay(game: game),
                    'complete': (_, game) =>
                        PrototypeResultOverlay(game: game, complete: true),
                    'failed': (_, game) =>
                        PrototypeResultOverlay(game: game, complete: false),
                  },
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AssetControl(
                        asset: ArrowGateAssets.uiButtonsCommonPillBlue,
                        label: strings.paused,
                        onTap: game.pausePrototype,
                      ),
                      _AssetControl(
                        asset: ArrowGateAssets.uiButtonsCommonPillGreen,
                        label: strings.restart,
                        onTap: game.restartPrototype,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.strings});

  final PrototypeStrings strings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF7FC8F8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(ArrowGateAssets.brandingLogoLogoStacked, width: 220),
            const SizedBox(height: 18),
            Image.asset(ArrowGateAssets.effectsLoadingDotsGold, width: 96),
            const SizedBox(height: 12),
            Text(strings.loading),
          ],
        ),
      ),
    );
  }
}

class _AssetControl extends StatelessWidget {
  const _AssetControl({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(asset, width: 104, fit: BoxFit.contain),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C2A1B),
            ),
          ),
        ],
      ),
    );
  }
}
