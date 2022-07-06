import 'package:flutter/material.dart';

class MissingInternetConnection extends StatelessWidget {
  const MissingInternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
            body:
                Center(child: Text("Internet connection lost. Reload app."))));
  }
}
