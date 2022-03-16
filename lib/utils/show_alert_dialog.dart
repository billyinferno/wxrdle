import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';
import 'package:wxrdle/utils/show_loader_dialog.dart';

Future<void> showAlertDialog({
  required BuildContext context,
  required String title,
  required String body,
  required AsyncCallback callback,
  required VoidCallback enableButton,
}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text("NEW WORD"),
              color: correctGuess,
              onPressed: (() async {
                // show loader
                showLoaderDialog(context);
                
                // reset the game
                await callback();
                enableButton();
                
                // remove the loader
                Navigator.of(context).pop();

                // remove the dialog
                Navigator.of(context).pop();
              })
            ),
          ],
        );
      }
    );
  }