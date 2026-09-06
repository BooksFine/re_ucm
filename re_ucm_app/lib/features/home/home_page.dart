import 'package:material_ui/material_ui.dart';

import 'home_page_landscape.dart';
import 'home_page_portrait.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840.0;
        return isWide ? const HomePageLandscape() : const HomePagePortrait();
      },
    );
  }
}
