import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'InnoStudy App',
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '    Hi, we are glad to see you at InnoStudy App. InnoStudy - is an mobile application that helps students of Innopolis University with education.\n Our application is a storing system for sharing abstracts, problem solutions and other stuff related to study. In this app students can create groups where they can share the content like images, documents, video etc. with other students.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'Structure',
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    '    First screen of app is Login page. To use this app you need to register new account or log in into existing one. The main screen of our app is the screen with groups. In groups you can find shared folders and files. In the bottom of each page you can see button Add to add group/folder/file. On settings page you can find and theme mode and your login. Also here you can log out from account.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'Permissions system',
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    '''
    Our app has a permission system for users and has following aspects:\n
  1. All users can:\n
    - See content of all created groups in app\n
    - Create and manage their own group\n
  2. Group creator can:\n
    - Add/delete any folders/files inside created group\n
    - Delete group\n
    - Add other people to manage group\n
  3. Manager of the group can:\n
    - Add folders/files inside group\n
  4. Creator of folder can:\n
    - Add folders/files inside this folder\n
    - Delete created folder\n
    - Add other people to manage folder\n
  5. Manager of folder can:\n
    - Add folders/files inside this folder\n
  6. Creator of file can:\n
    - Delete created file
                    ''',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFBCAAA4),
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
