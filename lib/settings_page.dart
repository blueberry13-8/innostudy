import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:work/theme_switcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int selectedTheme;

  @override
  void initState() {
    selectedTheme = DynamicTheme.of(context)!.themeId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text(
                'Choose theme of App',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CupertinoSlidingSegmentedControl(
                backgroundColor: Theme.of(context).backgroundColor,
                groupValue: selectedTheme,
                thumbColor: Colors.purple,
                onValueChanged: (value) async {
                  if (value == 0) {
                    selectedTheme = 0;
                    ThemeSwitcher.of(context).switchThemeMode(ThemeMode.system);
                  } else if (value == 1) {
                    selectedTheme = 1;
                    ThemeSwitcher.of(context).switchThemeMode(ThemeMode.light);
                  } else if (value == 2) {
                    selectedTheme = 2;
                    ThemeSwitcher.of(context).switchThemeMode(ThemeMode.dark);
                  }
                  await DynamicTheme.of(context)!.setTheme(selectedTheme);
                  setState(() {});
                },
                children: <int, Widget>{
                  0: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'System',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Light',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  2: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Dark',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
