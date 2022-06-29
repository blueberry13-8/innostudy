import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work/pessimistic_toast.dart';
import 'firebase_functions.dart';
import 'groups_page.dart';
import 'consumer.dart';

class HelloPage extends StatefulWidget {
  const HelloPage({Key? key}) : super(key: key);
  final Color mistakeColor = Colors.white;

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  String curPass = "";
  String curNick = "";

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      //Dynamically build widget
      child: SafeArea(
          child: StreamBuilder(
        stream: consumerStream,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          } else if (snapshot.hasData) {
            Consumer();
            return const GroupsPage();
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  Center(
                    child: Text(
                      "Welcome!",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 50,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    'E-mail',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (text) {
                        curNick = text;
                      },
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Enter email',
                        hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        iconColor: Theme.of(context).primaryColor,
                        hoverColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (text) {
                        curPass = text;
                      },
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: const Color(0xFFBCAAA4)),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: curNick,
                              password: curPass,
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              pessimisticToast('password is too weak', 4);
                            } else if (e.code == 'email-already-in-use') {
                              pessimisticToast(
                                  'The account already exists for that email.',
                                  7);
                            } else if (e.code == 'invalid-email') {
                              pessimisticToast('Email is malformed', 4);
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print(e);
                            }
                          }
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Color(0xff000000)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: const Color(0xFFBCAAA4)),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: curNick, password: curPass);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-disabled') {
                              pessimisticToast(
                                  'That account is currently unavailable', 4);
                            } else if (e.code == 'user-not-found') {
                              pessimisticToast('The account not found.', 4);
                            } else if (e.code == 'wrong-password') {
                              pessimisticToast('The password is incorrect.', 4);
                            } else if (e.code == 'invalid-email') {
                              pessimisticToast('Email is malformed', 4);
                            }
                          }
                        },
                        child: const Text(
                          'LogIn!',
                          style: TextStyle(color: Color(0xff000000)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      )),
    );
  }
}
