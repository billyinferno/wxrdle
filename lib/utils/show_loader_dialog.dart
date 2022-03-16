import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';

void showLoaderDialog(BuildContext context) {
  AlertDialog _alert = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: CircularProgressIndicator(
        color: correctGuess,
      ),
    ),
  );

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return _alert;
      }
  );
}