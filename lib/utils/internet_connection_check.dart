import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

bool _isInternetListening = false;
bool _isInternetLost = false;

void startListeningInternet(BuildContext context) {
  if (_isInternetListening) {
    return;
  }

  _isInternetListening = true;

  Connectivity connectivity = Connectivity();
  connectivity.onConnectivityChanged.listen((result) {
    if (result == ConnectivityResult.none) {
      debugPrint("Не появлюсь больше онлайн");
      _isInternetLost = true;
      showConnectionErrorAndCloseApp(context);
    } else {
      if (_isInternetLost) {
        _isInternetLost = false;
        Navigator.of(context).pop();
      }
      debugPrint("Привет Артём! Давай попьём чай");
    }
  }, onError: (error) {
    debugPrint("Ну чё там с деньгами");
    showConnectionErrorAndCloseApp(context);
  });
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
