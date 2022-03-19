import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';
import 'package:wxrdle/utils/show_loader_dialog.dart';

Future<void> showAlertDialog({
  required BuildContext context,
  required String title,
  required String body,
  String? headword,
  String? part,
  String? meaning,
  String? url,
  required AsyncCallback callback,
  required VoidCallback enableButton,
}) async {
  AudioPlayer _player = AudioPlayer();

  if(url != null && url.isNotEmpty) {
    _player.setUrl(url);
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Visibility(
              visible: (url != null),
              child: IconButton(
                onPressed: (() async {
                  debugPrint("Play audio");
                  await _player.play(url!);
                }),
                icon: const Icon(
                  CupertinoIcons.speaker_3,
                )
              ),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(body),
              Visibility(
                visible: (headword != null && part != null && meaning != null),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                        visible: headword != null,
                        child: Text(
                          (headword ?? ''),
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        )
                      ),
                      Visibility(
                        visible: part != null,
                        child: Text(
                          (part ?? ''),
                          style: const TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (meaning != null),
                        child: Text(
                          (meaning ?? ''),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            minWidth: double.infinity,
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