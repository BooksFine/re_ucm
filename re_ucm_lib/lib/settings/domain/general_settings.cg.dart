import 'package:freezed_annotation/freezed_annotation.dart';

import 'path_template.cg.dart';
import 'recent_books_view_mode.dart';
import 'save_format.dart';

part '../../.gen/settings/domain/general_settings.cg.freezed.dart';
part '../../.gen/settings/domain/general_settings.cg.g.dart';

@freezed
abstract class GeneralSettings with _$GeneralSettings {
  const GeneralSettings._();

  const factory GeneralSettings({
    required PathTemplate downloadPathTemplate,
    @Default(', ') String authorsPathSeparator,
    String? saveDirectory,
    @Default(SaveFormat.fb2Zip) SaveFormat saveFormat,
    @Default(false) bool autoSaveOnComplete,
    @Default(4) int parallelImageDownloads,
    @Default(4) int parallelChapterDownloads,
    @Default(<String>[]) List<String> pinnedPortalCodes,
    @Default(RecentBooksViewMode.compact) RecentBooksViewMode recentBooksViewMode,
  }) = _GeneralSettings;

  factory GeneralSettings.initial() => GeneralSettings(
    downloadPathTemplate: PathTemplate.initial(),
  );

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      _$GeneralSettingsFromJson(json);
}
