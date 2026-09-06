import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';

class SourcesController {
  SourcesController({String? initialCode}) {
    selectedCode = initialCode;
  }

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

  void initPinnedCodes(List<String> codes) {
    runInAction(() {
      _pinnedCodes.clear();
      _pinnedCodes.addAll(codes);
    });
  }

  void togglePin(String code, void Function(String) onPersist) {
    runInAction(() {
      if (_pinnedCodes.contains(code)) {
        _pinnedCodes.remove(code);
      } else {
        _pinnedCodes.add(code);
      }
    });
    onPersist(code);
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
}
