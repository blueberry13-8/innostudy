import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

bool _isInternetLost = false;
late BuildContext _mainContext;

void setMainContext(BuildContext context) {
  _mainContext = context;
}

void checkInternet() async {
  try {
    await http.get(Uri.parse("https://api.chucknorris.io/jokes/random"));
    if (_isInternetLost) {
      _isInternetLost = false;
      // ignore: use_build_context_synchronously
      Navigator.of(_mainContext).pop();
    }
  } catch (_) {
    debugPrint("Не появлюсь больше онлайн");
    if (_isInternetLost == false) {
      _isInternetLost = true;
      showConnectionErrorAndCloseApp(_mainContext);
    }
  }
}

Future<bool> checkInternetBool() async {
  try {
    await http.get(Uri.parse("https://api.chucknorris.io/jokes/random"));
    return true;
  } catch (_) {
    return false;
  }
}

void showConnectionErrorAndCloseApp(BuildContext upContext) {
  showDialog<void>(
    context: upContext,
    barrierDismissible: false,
    builder: (context) {
      var alertDialog = AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'No internet connection.',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: Text(
          'Your internet connection is lost. Please close and open the application again. If nothing changed, try to check your network.',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
      return alertDialog;
    },
  );
}
