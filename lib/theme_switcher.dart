import 'package:flutter/material.dart';

class ThemeSwitcher extends InheritedWidget {
  final ThemeSwitcherWidgetState data;

  const ThemeSwitcher({Key? key, required this.data, required Widget child})
      : super(key: key, child: child);

  static ThemeSwitcherWidgetState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType(aspect: ThemeSwitcher)
            as ThemeSwitcher).data;
  }

  @override
  bool updateShouldNotify(ThemeSwitcher oldWidget) {
    return this != oldWidget;
  }
}

class ThemeSwitcherWidget extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final Widget child;

  const ThemeSwitcherWidget(
      {Key? key, required this.initialThemeMode, required this.child})
      : super(key: key);

  @override
  ThemeSwitcherWidgetState createState() => ThemeSwitcherWidgetState();
}

class ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget> {
  late ThemeMode themeMode;

  void switchThemeMode(ThemeMode theme) {
    setState(() {
      themeMode = theme;
    });
  }

  @override
  void initState() {
    themeMode = widget.initialThemeMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(
      data: this,
      child: widget.child,
    );
  }
}