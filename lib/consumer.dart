import 'package:firebase_auth/firebase_auth.dart';
class Consumer{
  static User data = FirebaseAuth.instance.currentUser!;
  Consumer();
}