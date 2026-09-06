class CancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final listener in List.of(_listeners)) {
      try {
        listener();
      } catch (_) {}
    }
  }

  void attach(void Function() onCancel) {
    if (_isCancelled) {
      try {
        onCancel();
      } catch (_) {}
    } else {
      _listeners.add(onCancel);
    }
  }

  void detach(void Function() onCancel) {
    _listeners.remove(onCancel);
  }
}