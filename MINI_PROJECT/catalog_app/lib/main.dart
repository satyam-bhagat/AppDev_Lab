import 'package:flutter/material.dart';
import 'package:catalog_app/core/store.dart';
import 'package:catalog_app/utils/routes.dart';
import 'package:catalog_app/utils/themes.dart';
import 'package:velocity_x/velocity_x.dart';

// --- ADD THESE IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'package:catalog_app/firebase_options.dart';
// --------------------------

void main() async {
  // --- ADD THESE LINES ---
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // -----------------------

  runApp(VxState(store: MyStore(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      themeMode: ThemeMode.system,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      debugShowCheckedModeBanner: false,

      // --- USE THE NEW ROUTER CONFIG ---
      routerConfig: MyRoutes.router,
    );
  }
}
