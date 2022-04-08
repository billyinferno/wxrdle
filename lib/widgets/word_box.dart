import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';
import 'package:wxrdle/widgets/letter_box.dart';

class WordBox extends StatelessWidget {
  final String guess;
  final String answer;
  final int? length;
  final bool? checkAnswer;
  const WordBox({ Key? key, required this.answer, required this.guess, this.length, this.checkAnswer }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _length = (length ?? 5);
    bool _checkAnswer = (checkAnswer ?? false);
    String _answer = answer;
    String _currGuess = "";
    String _currAnswer = "";
    int _guessPos = -1;
    Map<int, Color> _letterBoxColor = {};
    Map<String, int> _result = {};
    double _width = (MediaQuery.of(context).size.width - (_length * 10)) / _length;
    if(_width > 50) {
      _width = 50;
    }

    // initialize all as transparent
    for(int i = 0; i < _length; i++) {
      _letterBoxColor[i] = Colors.transparent;
    }

    if(_checkAnswer) {
      // first loop thru all the guess and answer
      for(int i = 0; i < guess.length; i++) {
        _currGuess = guess.substring(i, (i + 1));
        _currAnswer = _answer.substring(i, (i + 1));
        if(_currGuess == _currAnswer) {
          _letterBoxColor[i] = correctGuess;
          _result[_currGuess] = 2;
          _answer = removeCharacter(_answer, i);
        }
      }

      // now scan thru all the guess on the answer
      for(int i = 0; i < guess.length; i++) {
        // only check if the color is transparent
        if(_letterBoxColor[i] == Colors.transparent) {
          _currGuess = guess.substring(i, (i + 1));
          _guessPos = _answer.indexOf(_currGuess);
          if(_guessPos >= 0) {
            _letterBoxColor[i] = locationGuess;
            _result[_currGuess] = 3;
            _answer = removeCharacter(_answer, _guessPos);
          }
          else {
            _letterBoxColor[i] = wrongGuess;
            _result[_currGuess] = 0;
          }
        }
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_length, (index) {
        _currGuess = "";
        // get the actual guess if the guess length > index
        if(guess.length > index) {
          _currGuess = guess.substring(index, (index + 1));
        }
        return LetterBox(
          color: _letterBoxColor[index],
          text: _currGuess,
          width: _width,
          height: _width,
        );
      }),
    );
  }

  String removeCharacter(String word, int index) {
    return word.substring(0, index) + " " + word.substring(index + 1);
  }
}
