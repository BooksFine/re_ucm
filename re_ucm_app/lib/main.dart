import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di.dart';
import 'core/logger.dart';
import 'core/navigation/router.dart';
import 'core/ui/theme.dart';
import 'features/ota/ota_service.dart';
import 'features/share_receiver/share_receiver.dart';

Future settingUpSystemUIOverlay() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

class MyWidgetsBinding extends WidgetsFlutterBinding {
  @override
  // ignore: must_call_super
  void handleMemoryPressure() {}
}

void main() async {
  MyWidgetsBinding();
  WidgetsFlutterBinding.ensureInitialized();

  await loggerInit();

  await settingUpSystemUIOverlay();
  final app = await AppDependencies.init(child: const MainApp());

  runApp(app);
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final router = createRouter(AppDependencies.of(context));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shareHandler(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OTAService.firstLaunch(AppDependencies.of(context).otaService);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      darkTheme: darkTheme,
      theme: lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
