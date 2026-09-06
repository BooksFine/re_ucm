enum Stages {
  none,
  downloading,
  decrypting,
  parsing,
  analyzing,
  imageDownloading,
  building,
  ziping,
  done,
  error,
}

extension StagesTitle on Stages {
  String get title => switch (this) {
    Stages.decrypting => 'Расшифровка глав',
    Stages.parsing => 'Построение структуры',
    Stages.imageDownloading => 'Загрузка изображений',
    Stages.downloading => 'Загрузка глав',
    Stages.building => 'Сборка книги',
    Stages.ziping => 'Упаковка архива',
    Stages.analyzing => 'Анализ книги',
    Stages.done => 'Загрузка завершена',
    Stages.error => 'Ошибка',
    _ => 'Подготовка...',
  };
}

enum ImageDownloadStatus { pending, downloading, completed, failed }

enum ChapterDownloadStatus { pending, downloading, completed, failed }

class ChapterDownloadTask {
  final int index;
  final String title;
  final ChapterDownloadStatus status;

  const ChapterDownloadTask({
    required this.index,
    required this.title,
    this.status = ChapterDownloadStatus.pending,
  });

  ChapterDownloadTask copyWith({
    int? index,
    String? title,
    ChapterDownloadStatus? status,
  }) {
    return ChapterDownloadTask(
      index: index ?? this.index,
      title: title ?? this.title,
      status: status ?? this.status,
    );
  }
}

class ImageDownloadTask {
  final String id;
  final int receivedBytes;
  final int? totalBytes;
  final ImageDownloadStatus status;

  const ImageDownloadTask({
    required this.id,
    this.receivedBytes = 0,
    this.totalBytes,
    this.status = ImageDownloadStatus.pending,
  });

  ImageDownloadTask copyWith({
    String? id,
    int? receivedBytes,
    int? totalBytes,
    ImageDownloadStatus? status,
  }) {
    return ImageDownloadTask(
      id: id ?? this.id,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
    );
  }

  double? get progress => (totalBytes != null && totalBytes! > 0)
      ? (receivedBytes / totalBytes!).clamp(0.0, 1.0)
      : null;
}

class Progress {
  var stage = Stages.none;
  int? current;
  int? total;
  List<ChapterDownloadTask> chapterTasks;
  List<ImageDownloadTask> activeTasks;
  String? message;

  Progress({
    this.stage = Stages.none,
    this.current,
    this.total,
    this.chapterTasks = const [],
    this.activeTasks = const [],
    this.message,
  });

  @override
  String toString() {
    List<String> params = [];

    if (stage != Stages.none) params.add('stage: $stage');
    if (current != null) params.add('current: $current');
    if (total != null) params.add('total: $total');
    if (chapterTasks.isNotEmpty) params.add('chapters: ${chapterTasks.length}');
    if (activeTasks.isNotEmpty) params.add('tasks: ${activeTasks.length}');
    if (message != null) params.add('message: $message');

    return 'Progress(${params.join(', ')})';
  }
}

extension ProgressDisplay on Progress {
  /// Единственная точка нормализации прогресса 0..1.
  double? get normalized {
    final cur = current;
    final tot = total;
    if (cur == null || tot == null || tot <= 0) return null;
    return (cur / tot).clamp(0.0, 1.0);
  }

  /// Единственная точка форматирования счётчика «12 / 40 (30%)».
  String get counterText {
    final cur = current;
    final tot = total;
    if (cur == null || tot == null) return message ?? stage.title;
    final pct = normalized;
    final pctStr = pct == null ? '' : ' (${(pct * 100).toInt()}%)';
    return '$cur / $tot$pctStr';
  }
}
