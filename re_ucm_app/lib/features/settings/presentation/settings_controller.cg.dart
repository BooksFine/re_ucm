import 'package:file_picker/file_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

part '../../../.gen/features/settings/presentation/settings_controller.cg.g.dart';

class SettingsController = SettingsControllerBase with _$SettingsController;

abstract class SettingsControllerBase with Store {
  final SettingsService service;

  SettingsControllerBase({required this.service}) {
    saveFormat = service.saveFormat;
    downloadPathTemplate = service.downloadPathTemplate;
    authorsPathSeparator = service.authorsPathSeparator;
    saveDirectory = service.saveDirectory;
    autoSaveOnComplete = service.autoSaveOnComplete;
    parallelImageDownloads = service.parallelImageDownloads;
    parallelChapterDownloads = service.parallelChapterDownloads;
    recentBooksViewMode = service.recentBooksViewMode;
  }

  @observable
  late RecentBooksViewMode recentBooksViewMode;

  @action
  void updateRecentBooksViewMode(RecentBooksViewMode mode) {
    recentBooksViewMode = mode;
    service.updateRecentBooksViewMode(mode);
  }

  @observable
  late SaveFormat saveFormat;

  @action
  void updateSaveFormat(SaveFormat format) {
    saveFormat = format;
    service.updateSaveFormat(format);
  }

  @observable
  late PathTemplate downloadPathTemplate;

  @action
  void updateDownloadPathTemplate(PathTemplate template) {
    downloadPathTemplate = template;
    service.updateDownloadPathTemplate(template);
  }

  @observable
  late String authorsPathSeparator;

  @action
  void updateAuthorsPathSeparator(String separator) {
    authorsPathSeparator = separator;
    service.updateAuthorsPathSeparator(separator);
  }

  @observable
  String? saveDirectory;

  @action
  void updateSaveDirectory(String? path) {
    saveDirectory = path;
    service.updateSaveDirectory(path);
  }

  @observable
  late bool autoSaveOnComplete;

  @action
  void updateAutoSaveOnComplete(bool value) {
    autoSaveOnComplete = value;
    service.updateAutoSaveOnComplete(value);
  }

  @observable
  late int parallelImageDownloads;

  @action
  void updateParallelImageDownloads(int value) {
    parallelImageDownloads = value;
    service.updateParallelImageDownloads(value);
  }

  @observable
  late int parallelChapterDownloads;

  @action
  void updateParallelChapterDownloads(int value) {
    parallelChapterDownloads = value;
    service.updateParallelChapterDownloads(value);
  }

  final Observable<bool> _isPickingDirectory = Observable(false);

  bool get isPickingDirectory => _isPickingDirectory.value;

  Future<void> pickSaveDirectory() async {
    if (isPickingDirectory) return;
    runInAction(() => _isPickingDirectory.value = true);
    try {
      final result = await FilePicker.getDirectoryPath();
      if (result != null) {
        updateSaveDirectory(result);
      }
    } finally {
      runInAction(() => _isPickingDirectory.value = false);
    }
  }

  void setAlwaysAskDirectory(bool alwaysAsk) {
    if (alwaysAsk) {
      updateSaveDirectory(null);
      updateAutoSaveOnComplete(false);
    } else {
      pickSaveDirectory();
    }
  }
}
