import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di.dart';
import 'core/navigation/router.dart';
import 'core/ui/theme.dart';

Future settingUpSystemUIOverlay() async {
// Setting SysemUIOverlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
// Setting SystmeUIMode
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

  await settingUpSystemUIOverlay();
  await appInit();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
