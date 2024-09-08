enum Stages {
  none,
  downloading,
  decrypting,
  analyzing,
  imageDownloading,
  building,
  ziping,
  done,
  error,
}

class Progress {
  var stage = Stages.none;
  int? current;
  int? total;
  String? message;

  Progress({
    this.stage = Stages.none,
    this.current,
    this.total,
    this.message,
  });

  @override
  String toString() {
    List<String> params = [];

    if (stage != Stages.none) params.add('stage: $stage');
    if (current != null) params.add('current: $current');
    if (total != null) params.add('total: $total');
    if (message != null) params.add('message: $message');

    return 'Progress(${params.join(', ')})';
  }
}
