import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';

class KeyboardButton extends StatelessWidget {
  final String char;
  final int enabled;
  final Function(String) onPress;
  const KeyboardButton({ super.key, required this.char, required this.enabled, required this.onPress });

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width - 20) / 10;
    if (width > 50) {
      width = 50;
    }

    Color color = buttonBackground;
    switch(enabled) {
      case 0:
        color = buttonDisableBackground;
        break;
      case 1:
        color = buttonBackground;
        break;
      case 2:
        color = correctGuess;
        break;
      case 3:
        color = locationGuess;
        break;
      default:
        color = buttonBackground;
        break;
    }
    return SizedBox(
      width: width,
      height: 50,
      child: InkWell(
        onTap: (() {
          onPress(char);
        }),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.all(2),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              char,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor
              ),
            ),
          ),
        ),
      ),
    );
  }
}