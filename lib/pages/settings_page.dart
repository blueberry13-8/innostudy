import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/consumer.dart';
import 'package:work/pages/info_page.dart';

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
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Choose theme of App',
                    // style: TextStyle(
                    //   fontSize: 25,
                    //   color: Theme.of(context).primaryColor,
                    // ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoSlidingSegmentedControl(
                    backgroundColor: Theme.of(context).hoverColor,
                    groupValue: selectedTheme,
                    thumbColor: Theme.of(context).focusColor,
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
                          style: Theme.of(context).textTheme.labelLarge,
                          // style: TextStyle(
                          //   color: Theme.of(context).primaryColor,
                          // ),
                        ),
                      ),
                      1: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Light',
                          style: Theme.of(context).textTheme.labelLarge,
                          // style: TextStyle(
                          //   color: Theme.of(context).primaryColor,
                          // ),
                        ),
                      ),
                      2: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Dark',
                          // style: TextStyle(
                          //   color: Theme.of(context).primaryColor,
                          // ),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Account information',
                    // style: TextStyle(
                    //   color: Theme.of(context).primaryColor,
                    //   fontSize: 25,
                    // ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 5, left: 15, right: 15),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hoverColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'E-mail',
                            // style: TextStyle(
                            //   color: Theme.of(context).primaryColor,
                            //   fontSize: 23,
                            // ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 300,
                            child: Text(
                              Consumer.data.email!,
                              // style: TextStyle(
                              //   color: Theme.of(context).primaryColor,
                              //   fontSize: 20,
                              // ),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Log out',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 80,
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          child: Text(
            'About this app',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InfoPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
