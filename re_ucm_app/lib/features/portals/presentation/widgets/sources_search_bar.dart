import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/widgets/app_search_bar.dart';

class SourcesSearchBar extends StatelessWidget {
  const SourcesSearchBar({
    super.key,
    required this.controller,
    required this.totalCount,
    required this.searchQuery,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int totalCount;
  final String searchQuery;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: controller,
      hint: 'Поиск по $totalCount источникам...',
      searchQuery: searchQuery,
      onChanged: onChanged,
    );
  }
}
