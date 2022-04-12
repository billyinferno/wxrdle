import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';

class KeyboardButton extends StatelessWidget {
  final String char;
  final int enabled;
  final Function(String) onPress;
  const KeyboardButton({ Key? key, required this.char, required this.enabled, required this.onPress }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = (MediaQuery.of(context).size.width - 20) / 10;
    if (_width > 50) {
      _width = 50;
    }

    Color _color = buttonBackground;
    switch(enabled) {
      case 0:
        _color = buttonDisableBackground;
        break;
      case 1:
        _color = buttonBackground;
        break;
      case 2:
        _color = correctGuess;
        break;
      case 3:
        _color = locationGuess;
        break;
      default:
        _color = buttonBackground;
        break;
    }
    return SizedBox(
      width: _width,
      height: 50,
      child: InkWell(
        onTap: (() {
          onPress(char);
        }),
        child: Container(
          decoration: BoxDecoration(
            color: _color,
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