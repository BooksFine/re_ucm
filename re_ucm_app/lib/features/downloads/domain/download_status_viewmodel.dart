/// Единая view-модель статуса для live/progress/list.
/// Все три виджета обязаны использовать её вместо своих формул.
typedef DownloadStatusViewModel = ({
  String title,
  String statusText,
  double? progress,
});

DownloadStatusViewModel buildDownloadStatusViewModel({
  required String title,
  required String statusText,
  required double? progress,
}) => (
  title: title,
  statusText: statusText,
  progress: progress,
);
