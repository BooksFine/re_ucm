enum RecentBooksViewMode {
  compact('compact', 'Компактный'),
  detailed('detailed', 'Подробный');

  final String code;
  final String label;

  const RecentBooksViewMode(this.code, this.label);

  String toJson() => name;

  static RecentBooksViewMode fromJson(String? value) {
    if (value == null) return RecentBooksViewMode.compact;
    try {
      return RecentBooksViewMode.values.byName(value);
    } catch (_) {
      return RecentBooksViewMode.compact;
    }
  }
}
