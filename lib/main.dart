import 'dart:async';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:work/firebase/firebase_functions.dart';
import 'package:work/pages/missing_internet_connection.dart';
import 'package:work/utils/internet_connection_check.dart';
import 'firebase/firebase_options.dart';
import 'pages/hello_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if (!(await checkInternetBool())) {
    runApp(const MissingInternetConnection());
    return;
  }

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    loadAppFirebase();
    runApp(
      EasyDynamicThemeWidget(
        child: const InnoStudyApp(),
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
    return MaterialApp(
      title: 'InnoStudy',
      theme: ThemeData(
        hoverColor: const Color(0xffdbe6ff),
        focusColor: const Color(0xffABC4FF),
        scaffoldBackgroundColor: const Color(0xffEDF2FB),
        backgroundColor: const Color(0xffEDF2FB),
        primaryColor: Colors.black87,
        appBarTheme: const AppBarTheme(
          color: Color(0xff85c0ff),
          foregroundColor: Colors.black87, //Color(0xffEDF2FB),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xffABC4FF),
          foregroundColor: Colors.black87,
        ),
        brightness: Brightness.light,
        cardTheme: const CardTheme(
          color: Color(0xffCCDBFD),
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffABC4FF),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color.fromRGBO(53, 62, 84, 1.0),
        backgroundColor: Colors.blueGrey,
        hoverColor: Colors.blueGrey,
        focusColor: Colors.blueGrey[300],
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(45, 80, 115, 1.0),
          shadowColor: Color.fromRGBO(50, 85, 120, 1.0),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[300],
          ),
        ),
      ),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: const HelloPage(),
    );
  }
}
