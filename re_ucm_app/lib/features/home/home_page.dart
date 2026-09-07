import 'package:material_ui/material_ui.dart';

import '../../core/ui/tokens.dart';
import 'home_page_landscape.dart';
import 'home_page_portrait.dart';
import 'widgets/link_forwarder_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LinkForwarderController _forwarderController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _forwarderController = LinkForwarderController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _forwarderController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.homeSplit;
        return isWide
            ? HomePageLandscape(
                forwarderController: _forwarderController,
                textController: _textController,
              )
            : HomePagePortrait(
                forwarderController: _forwarderController,
                textController: _textController,
              );
      },
    );
  }
}
