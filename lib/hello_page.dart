import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work/PessimisticToast.dart';
import 'firebase_functions.dart';
import 'groups_page.dart';
import 'consumer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HelloPage extends StatefulWidget {
  HelloPage({Key? key}) : super(key: key);
  Color mistake_color = Colors.white;

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  String curPass = "";
  String curNick = "";

  @override
  Widget build(BuildContext context) {
    return Material(
      //Dynamicly build widget
      child: SafeArea(
          child: StreamBuilder(
        stream: consumerStream,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return const Text("Idiot");
          } else if (snapshot.hasData) {
            Consumer();
            return GroupsPage();
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                  ),
                  Center(child: Text("Welcome!", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w400),),),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'E-mail',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: TextField(
                      onChanged: (text) {
                        curNick = text;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter email',
                      ),
                    ),
                    height: 40,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    child: TextField(
                      onChanged: (text) {
                        curPass = text;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                    ),
                    height: 40,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFFBCAAA4)),
                        onPressed: () async {
                          try {
                            final credential = await FirebaseAuth.instance
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
                            print(e);
                          }
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(color: Color(0xff000000)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFFBCAAA4)),
                        onPressed: () async {
                          try {
                            final credential = await FirebaseAuth.instance
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
                            }
                            else if (e.code == 'invalid-email') {
                              pessimisticToast('Email is malformed', 4);
                            }
                          }
                        },
                        child: Text(
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
