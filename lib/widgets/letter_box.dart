import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';

class LetterBox extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? width;
  final double? height;
  const LetterBox({ super.key, this.color, this.text, this.width, this.height });

  @override
  Widget build(BuildContext context) {
    Color bgColor = (color ?? Colors.transparent);
    double currWidth = (width ?? 50);
    double currHeight = (height ?? 50);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: buttonBackground,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        color: bgColor,
      ),
      width: currWidth,
      height: currHeight,
      margin: const EdgeInsets.all(5),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          (text ?? ""),
          style: TextStyle(
            fontSize: (30 * (currWidth / 50)),
            color: textColor,
          ),
        ),
      )
    );
  }
}