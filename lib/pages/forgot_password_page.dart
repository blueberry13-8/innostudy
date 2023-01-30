import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work/utils/pessimistic_toast.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String mail = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 150,
              ),
              Center(
                child: Text(
                  'Reset password',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 40,
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
                    mail = text;
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
                height: 50,
              ),
              Center(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Color(0xff000000),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: mail);
                        if (context.mounted) {
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
                                  Navigator.of(context).pop();
                                },
                              );
                              var alertDialog = AlertDialog(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                title: Text(
                                  'Reset password',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                content: Text(
                                  "The email with link for resetting password has been sent to your email. If you don't see it check your spam folder.",
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
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'invalid-email') {
                          pessimisticToast('Email is malformed', 4);
                        } else if (e.code == 'user-disabled') {
                          pessimisticToast(
                              'That account is currently unavailable', 4);
                        } else if (e.code == 'user-not-found') {
                          pessimisticToast('The account not found', 4);
                        } else {
                          if (kDebugMode) {
                            print(e.code);
                          }
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xff000000),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
