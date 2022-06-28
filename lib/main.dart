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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InnoStudy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HelloPage(),
    );
  }
}
