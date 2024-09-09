import 'package:flutter/material.dart';

import '../share_receiver/share_receiver.dart';
import 'home_page_landscape.dart';
import 'home_page_portrait.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shareHandler(context);
  }

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
