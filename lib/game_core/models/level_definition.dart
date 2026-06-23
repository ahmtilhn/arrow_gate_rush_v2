class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.requiredArrowIds,
    this.canFailOnLives = true,
    this.hardModeInvalidTapFails = false,
    this.timeoutEnabled = false,
  });

  final String id;
  final Set<String> requiredArrowIds;
  final bool canFailOnLives;
  final bool hardModeInvalidTapFails;
  final bool timeoutEnabled;
}
