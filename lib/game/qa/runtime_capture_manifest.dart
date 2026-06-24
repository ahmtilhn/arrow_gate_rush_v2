class RuntimeCaptureManifest {
  const RuntimeCaptureManifest._();

  static const requiredFields = <String>{
    'filename',
    'captureMethod',
    'platform',
    'deviceModel',
    'screenResolution',
    'appPackageId',
    'buildMode',
    'captureTimestampUtc',
    'gameState',
    'levelId',
    'expectedVisibleComponents',
    'assetGeneratedPreview',
  };

  static bool isValidEntry(Map<String, Object?> entry) {
    if (!requiredFields.every(entry.containsKey)) {
      return false;
    }
    if (entry['assetGeneratedPreview'] != false) {
      return false;
    }
    if (entry['platform'] != 'Android') {
      return false;
    }
    if (entry['buildMode'] != 'debug') {
      return false;
    }
    final filename = entry['filename'];
    final components = entry['expectedVisibleComponents'];
    return filename is String &&
        filename.endsWith('.png') &&
        components is List &&
        components.isNotEmpty;
  }
}
