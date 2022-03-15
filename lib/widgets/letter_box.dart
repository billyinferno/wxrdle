import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';

class LetterBox extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? width;
  final double? height;
  const LetterBox({ Key? key, this.color, this.text, this.width, this.height }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _bgColor = (color ?? Colors.transparent);
    double _width = (width ?? 50);
    double _height = (height ?? 50);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: buttonBackground,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        color: _bgColor,
      ),
      width: _width,
      height: _height,
      margin: const EdgeInsets.all(5),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          (text ?? ""),
          style: TextStyle(
            fontSize: (30 * (_width / 50)),
            color: textColor,
          ),
        ),
      )
    );
  }
}