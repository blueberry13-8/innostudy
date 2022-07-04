import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> showVladanchik(BuildContext upContext, String nameOfRemovable,
    VoidCallback onConfirm) async {
  return showDialog<void>(
    context: upContext,
    barrierDismissible: false,
    builder: (context) {
      var cancelButton = TextButton(
        child: Text(
          'Cancel',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        onPressed: () {
          if (kDebugMode) {
            print('Canceled');
          }
          Navigator.of(context).pop();
        },
      );
      var confirmButton = TextButton(
        child: Text(
          'Confirm',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        onPressed: () async {
          if (kDebugMode) {
            print('Confirmed');
          }
          Navigator.of(context).pop();
          onConfirm();
        },
      );
      var alertDialog = AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Deleting of $nameOfRemovable',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: Text(
          'Are you sure about deleting $nameOfRemovable? It will be deleted without ability to restore.',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          cancelButton,
          confirmButton,
        ],
      );
      return alertDialog;
    },
  );
}
