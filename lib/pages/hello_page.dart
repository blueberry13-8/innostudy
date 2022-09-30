import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work/pages/forgot_password_page.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/utils/pessimistic_toast.dart';
import '../firebase/firebase_functions.dart';
import '../utils/internet_connection_check.dart';
import 'groups_page.dart';
import '../utils/consumer.dart';

class HelloPage extends StatefulWidget {
  const HelloPage({Key? key}) : super(key: key);
  final Color mistakeColor = Colors.white;

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  String curPass = "";
  String curNick = "";
  bool _newbie = false;

  @override
  void initState() {
    super.initState();
    setMainContext(context);
    Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        checkInternet();
      },
    );
  }

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
            } else if (snapshot.hasData && Consumer.data.emailVerified) {
              Consumer();
              return GroupsPage(openTutorial: _newbie);
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
                          fontWeight: FontWeight.w400,
                        ),
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
                        obscureText: true,
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
                          onPressed: () async {
                            try {
                              var newUser = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: curNick,
                                password: curPass,
                              );
                              await newUser.user?.sendEmailVerification();
                              _newbie = true;
                              await addRegisteredUser(curNick);
                              Consumer();
                              setState(() {});
                              showDialog(
                                context: context,
                                builder: (context) {
                                  var button = TextButton(
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    },
                                  );
                                  var alertDialog = AlertDialog(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    title: Text(
                                      'Email confirmation',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    content: Text(
                                      "Please, check your email to verify your account. If you haven't got the email, check your spam folder.",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    actions: [
                                      button,
                                    ],
                                  );
                                  return alertDialog;
                                },
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
                            style: TextStyle(
                              color: Color(0xff000000),
                            ),
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
                          onPressed: () async {
                            try {
                              var user = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: curNick, password: curPass);
                              Consumer();
                              Consumer.data = user.user!;
                              if (!user.user!.emailVerified) {
                                _newbie = true;
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    var buttonResendEmail = TextButton(
                                      child: Text(
                                        'Resend email',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      onPressed: () {
                                        user.user?.sendEmailVerification();
                                        Navigator.of(context).pop();
                                        pessimisticToast(
                                            'New email has been sent', 4);
                                      },
                                    );
                                    var buttonClose = TextButton(
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                    var alertDialog = AlertDialog(
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      title: Text(
                                        'Your email is not confirmed',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      content: Text(
                                        "Please, check your email to verify your account. If you haven't got the email, check your spam folder or try to resend the email.",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      actions: [
                                        buttonResendEmail,
                                        buttonClose,
                                      ],
                                    );
                                    return alertDialog;
                                  },
                                );
                              } else if (user.user!.emailVerified) {
                                setState(() {});
                                //Consumer();
                                //openGroupPage();
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-disabled') {
                                pessimisticToast(
                                    'That account is currently unavailable', 4);
                              } else if (e.code == 'user-not-found') {
                                pessimisticToast('The account not found.', 4);
                              } else if (e.code == 'wrong-password') {
                                pessimisticToast(
                                    'The password is incorrect.', 4);
                              } else if (e.code == 'invalid-email') {
                                pessimisticToast('Email is malformed', 4);
                              }
                            }
                          },
                          child: const Text(
                            'LogIn!',
                            style: TextStyle(
                              color: Color(0xff000000),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Center(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Color(0xff000000),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const ForgotPasswordPage();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
