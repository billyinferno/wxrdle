import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';

class KeyboardButton extends StatelessWidget {
  final String char;
  final bool enabled;
  final Function(String) onPress;
  const KeyboardButton({ Key? key, required this.char, required this.enabled, required this.onPress }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = (MediaQuery.of(context).size.width - 20) / 10;
    if (_width > 50) {
      _width = 50;
    }
    return SizedBox(
      width: _width,
      height: 50,
      child: InkWell(
        onTap: (() {
          if(enabled) {
            onPress(char);
          }
        }),
        child: Container(
          decoration: BoxDecoration(
            color: (enabled ? buttonBackground : buttonDisableBackground),
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