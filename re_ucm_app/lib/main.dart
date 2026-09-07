import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'core/app_startup.dart';
import 'core/constants.dart';
import 'core/di.dart';
import 'core/logger.dart';
import 'core/navigation/router.dart';
import 'core/ui/theme.dart';
import 'features/downloads/presentation/download_modal.dart';
import 'features/share_receiver/share_receiver.dart';

const e2eOverlayStyle = SystemUiOverlayStyle(
  systemStatusBarContrastEnforced: false,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
);

class MyWidgetsBinding extends WidgetsFlutterBinding {
  @override
  // ignore: must_call_super
  void handleMemoryPressure() {
    PaintingBinding.instance.imageCache.maximumSizeBytes ~/= 2;
  }
}

void main() async {
  MyWidgetsBinding();
  WidgetsFlutterBinding.ensureInitialized();
  resetOpenModalsRegistry();

  await loggerInit();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final app = await AppDependencies.init(child: const MainApp());

  runApp(app);
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final router = createRouter();

  @override
  void initState() {
    super.initState();
    ShareReceiverService.init();
  }

  @override
  void dispose() {
    ShareReceiverService.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStartup.checkUpdates(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: e2eOverlayStyle,
      child: MaterialApp.router(
        title: appName,
        darkTheme: darkTheme,
        theme: lightTheme,
        themeMode: ThemeMode.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
