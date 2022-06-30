import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'hello_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InnoStudyApp());
}

class InnoStudyApp extends StatelessWidget {
  const InnoStudyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.system,
      home: const HelloPage(),
    );
  }
}
