import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
pessimisticToast(String error, int duration){
  Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: duration,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}