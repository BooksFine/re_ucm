import 'package:flutter/material.dart';

import 'home_page_landscape.dart';
import 'home_page_portrait.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(forceMaterialTransparency: true, toolbarHeight: 0),
      body: MediaQuery.sizeOf(context).width < 600
          ? const HomePagePortrait()
          : const HomePageLandscape(),
    );
  }
}
