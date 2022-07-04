import 'package:flutter/material.dart';

class ActionProgress extends StatelessWidget {
  const ActionProgress({required this.parentContext, Key? key}) : super(key: key);
  final BuildContext parentContext;
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.2;
    return Container(
      alignment: Alignment.center,
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: Theme.of(parentContext).primaryColor,
      ),
    );
  }
}
