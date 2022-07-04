import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:work/consumer.dart';
import 'package:work/info_page.dart';

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
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
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
                //thumbColor: Colors.purple,
                thumbColor: const Color(0xFFBCAAA4),
                onValueChanged: (value) async {
                  if (value == 0) {
                    selectedTheme = 0;
                    EasyDynamicTheme.of(context).changeTheme(dynamic: true);
                  } else if (value == 1) {
                    selectedTheme = 1;
                    EasyDynamicTheme.of(context).changeTheme(dark: false);
                  } else if (value == 2) {
                    selectedTheme = 2;
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
              const SizedBox(
                height: 40,
              ),
              Text(
                'Account information',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Your e-mail',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 23,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 300,
                child: Text(
                  Consumer.data.email!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFBCAAA4),
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  //setState(() {});
                },
                child: const Text('Log out'),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFBCAAA4),
                ),
                child: const Text('About this app'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
