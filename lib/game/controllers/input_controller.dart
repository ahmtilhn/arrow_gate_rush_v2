class InputController {
  bool _locked = false;

  bool get isLocked => _locked;

  bool tryLock() {
    if (_locked) {
      return false;
    }
    _locked = true;
    return true;
  }

  void unlock() {
    _locked = false;
  }
}
