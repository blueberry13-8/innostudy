import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:work/firebase_functions.dart';
import 'package:work/theme_switcher.dart';
import 'firebase_options.dart';
import 'hello_page.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    loadAppFirebase();
    runApp(
      const ThemeSwitcherWidget(
        initialThemeMode: ThemeMode.system,
        child: InnoStudyApp(),
      ),
    );
  },
      ((error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack)));
}

class InnoStudyApp extends StatelessWidget {
  const InnoStudyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final light = ThemeData(
    //   scaffoldBackgroundColor: Colors.white,
    //   backgroundColor: Colors.white,
    //   primaryColor: Colors.black87,
    //   appBarTheme: AppBarTheme(
    //     color: Colors.lightGreen[300],
    //     foregroundColor: Colors.white,
    //   ),
    //   floatingActionButtonTheme: FloatingActionButtonThemeData(
    //     backgroundColor: Colors.lightGreen[300],
    //   ),
    //   brightness: Brightness.light,
    //   cardTheme: CardTheme(
    //     color: Colors.yellow[100],
    //   ),
    //   iconTheme: const IconThemeData(
    //     color: Colors.black87,
    //     size: 25,
    //   ),
    //   textTheme: const TextTheme(
    //     bodyText1: TextStyle(
    //       color: Colors.black,
    //       fontSize: 18,
    //     ),
    //   ),
    // );
    // final dark = ThemeData(
    //   primaryColor: Colors.white,
    //   scaffoldBackgroundColor: const Color.fromRGBO(53, 62, 84, 1.0),
    //   backgroundColor: Colors.blueGrey,
    //   focusColor: Colors.indigo,
    //   appBarTheme: const AppBarTheme(
    //     color: Color.fromRGBO(45, 80, 115, 1.0),
    //     shadowColor: Color.fromRGBO(50, 85, 120, 1.0),
    //     foregroundColor: Colors.white,
    //   ),
    //   floatingActionButtonTheme: const FloatingActionButtonThemeData(
    //     backgroundColor: Color.fromRGBO(45, 80, 115, 1.0),
    //     foregroundColor: Colors.white,
    //   ),
    //   cardTheme: const CardTheme(
    //     color: Color.fromRGBO(89, 97, 122, 1),
    //   ),
    //   iconTheme: const IconThemeData(
    //     color: Colors.white,
    //     size: 25,
    //   ),
    //   textTheme: const TextTheme(
    //     bodyText1: TextStyle(
    //       color: Colors.white,
    //       fontSize: 18,
    //     ),
    //   ),
    // );
    // var brightness = SchedulerBinding.instance.platformDispatcher;
    // bool darkMode = brightness == Brightness.dark;
    // var system = darkMode ? dark : light;
    // final themeCollection = ThemeCollection(themes: {
    //   0: system,
    //   1: light,
    //   2: dark,
    // });
    // return DynamicTheme(
    //   themeCollection: themeCollection,
    //   defaultThemeId: 0,
    //   builder: (context, theme) {
    //     return MaterialApp(
    //       title: 'InnoStudy',
    //       theme: theme,
    //       home: const HelloPage(),
    //     );
    //   },
    // );
    return MaterialApp(
      title: 'InnoStudy',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        primaryColor: Colors.black87,
        appBarTheme: AppBarTheme(
          color: Colors.lightGreen[300],
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.lightGreen[300],
        ),
        brightness: Brightness.light,
        cardTheme: CardTheme(
          color: Colors.yellow[100],
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
          size: 25,
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color.fromRGBO(53, 62, 84, 1.0),
        backgroundColor: Colors.blueGrey,
        focusColor: Colors.indigo,
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(45, 80, 115, 1.0),
          shadowColor: Color.fromRGBO(50, 85, 120, 1.0),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(45, 80, 115, 1.0),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Color.fromRGBO(89, 97, 122, 1),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 25,
        ),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      themeMode: ThemeSwitcher.of(context).themeMode,
      home: const HelloPage(),
    );
  }
}
