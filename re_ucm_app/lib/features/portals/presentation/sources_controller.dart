import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

/// Чистые функции партиционирования видимого списка по пинам.
/// Вне класса: без состояния, тестируются изолированно.
List<Portal> pinnedVisible(List<Portal> visible, Set<String> pins) =>
    [for (final p in visible) if (pins.contains(p.code)) p];

List<Portal> otherVisible(List<Portal> visible, Set<String> pins) =>
    [for (final p in visible) if (!pins.contains(p.code)) p];

/// Неизменяемый срез данных для отображения источников в UI.
class SourcesView {
  const SourcesView({
    required this.visible,
    required this.pinned,
    required this.other,
    required this.validCode,
    required this.isSearching,
    required this.pins,
  });

  final List<Portal> visible;
  final List<Portal> pinned;
  final List<Portal> other;
  final String? validCode;
  final bool isSearching;
  final Set<String> pins;

  factory SourcesView.resolve(
    SourcesController controller,
    List<Portal> allPortals,
  ) {
    final visible = controller.filterPortals(allPortals);
    final isSearching = controller.searchQuery.trim().isNotEmpty;
    final pins = controller.pinnedCodes.toSet();
    final pinned =
        isSearching ? const <Portal>[] : pinnedVisible(visible, pins);
    final other = isSearching ? visible : otherVisible(visible, pins);
    return SourcesView(
      visible: visible,
      pinned: pinned,
      other: other,
      validCode: controller.validSelectedCode(visible),
      isSearching: isSearching,
      pins: pins,
    );
  }
}

/// View-model страницы источников. Держит только UI-состояние
/// (выбор, поиск, пины); персистентность пинов — внутри через
/// [SettingsService], колбэк из page больше не нужен.
///
/// Зеркало пинов ([_pinnedCodes]) оставлено осознанно: [SettingsService]
/// не является MobX-Store, поэтому прямое чтение
/// `settings.pinnedPortalCodes` внутри Observer нереактивно.
/// Прямое чтение станет возможным после миграции SettingsService
/// на Store с кодогенерацией в re_ucm_lib.
class SourcesController {
  SourcesController({String? initialCode}) {
    selectedCode = initialCode;
  }

  SettingsService? _settings;

  final Observable<String?> _selectedCode = Observable(null);
  final Observable<String> _searchQuery = Observable('');
  final ObservableList<String> _pinnedCodes = ObservableList<String>();

  String? get selectedCode => _selectedCode.value;
  set selectedCode(String? value) =>
      runInAction(() => _selectedCode.value = value);

  String get searchQuery => _searchQuery.value;
  set searchQuery(String value) =>
      runInAction(() => _searchQuery.value = value);

  List<String> get pinnedCodes => _pinnedCodes;

  /// Идемпотентно: можно вызывать из didChangeDependencies.
  /// Локальный optimistic-пин не перетирается, т.к. синхронизация
  /// идёт из того же [SettingsService], куда пишет [togglePin].
  void attachSettings(SettingsService settings) {
    _settings = settings;
    _syncPins();
  }

  void togglePin(String code) {
    final settings = _settings;
    if (settings != null) {
      settings.togglePinPortal(code);
      _syncPins();
    } else {
      runInAction(() {
        if (_pinnedCodes.contains(code)) {
          _pinnedCodes.remove(code);
        } else {
          _pinnedCodes.add(code);
        }
      });
    }
  }

  void _syncPins() {
    final settings = _settings;
    if (settings == null) return;
    final codes = settings.pinnedPortalCodes;
    runInAction(() {
      _pinnedCodes.clear();
      _pinnedCodes.addAll(codes);
    });
  }

  void selectPortal(String code) {
    if (_selectedCode.value != code) {
      runInAction(() => _selectedCode.value = code);
    }
  }

  List<Portal> filterPortals(List<Portal> allPortals) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return allPortals;
    return allPortals.where((p) {
      final nameMatch = p.name.toLowerCase().contains(query);
      final codeMatch = p.code.toLowerCase().contains(query);
      final urlMatch = p.url.toLowerCase().contains(query);
      return nameMatch || codeMatch || urlMatch;
    }).toList();
  }

  /// Фолбэк выбора: текущий код, если он видим, иначе первый видимый.
  /// Раньше дублировался в wide master и detail.
  String? validSelectedCode(List<Portal> visible) {
    if (visible.isEmpty) return null;
    final current = _selectedCode.value;
    if (current != null && visible.any((p) => p.code == current)) {
      return current;
    }
    return visible.first.code;
  }
}
