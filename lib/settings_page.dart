import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

int selectedTheme = 0;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
              const SizedBox(
                height: 10,
              ),
              Text(
                'Choose theme of App',
                style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoSlidingSegmentedControl(
                backgroundColor: Theme.of(context).backgroundColor,
                groupValue: selectedTheme,
                thumbColor: Colors.purple,
                onValueChanged: (value) async {
                  if (value == 0) {
                    selectedTheme = 0;
                    //ThemeSwitcher.of(context).switchThemeMode(ThemeMode.system);
                    EasyDynamicTheme.of(context).changeTheme(dynamic: true);
                  } else if (value == 1) {
                    selectedTheme = 1;
                    //ThemeSwitcher.of(context).switchThemeMode(ThemeMode.light);
                    EasyDynamicTheme.of(context).changeTheme(dark: false);
                  } else if (value == 2) {
                    selectedTheme = 2;
                    //ThemeSwitcher.of(context).switchThemeMode(ThemeMode.dark);
                    EasyDynamicTheme.of(context).changeTheme(dark: true);
                  }
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
