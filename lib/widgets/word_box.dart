import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';
import 'package:wxrdle/widgets/letter_box.dart';

class WordBox extends StatelessWidget {
  final String guess;
  final String answer;
  final int? length;
  final bool? checkAnswer;
  const WordBox({ super.key, required this.answer, required this.guess, this.length, this.checkAnswer });

  @override
  Widget build(BuildContext context) {
    int currLength = (length ?? 5);
    bool currCheckAnswer = (checkAnswer ?? false);
    String currAnswer = answer;
    String currGuess = "";
    String currAnswer0 = "";
    int guessPos = -1;
    Map<int, Color> letterBoxColor = {};
    Map<String, int> result = {};
    double width = (MediaQuery.of(context).size.width - (currLength * 10)) / currLength;
    if(width > 50) {
      width = 50;
    }

    // initialize all as transparent
    for(int i = 0; i < currLength; i++) {
      letterBoxColor[i] = Colors.transparent;
    }

    if(currCheckAnswer) {
      // first loop thru all the guess and answer
      for(int i = 0; i < guess.length; i++) {
        currGuess = guess.substring(i, (i + 1));
        currAnswer0 = currAnswer.substring(i, (i + 1));
        if(currGuess == currAnswer0) {
          letterBoxColor[i] = correctGuess;
          result[currGuess] = 2;
          currAnswer = removeCharacter(currAnswer, i);
        }
      }

      // now scan thru all the guess on the answer
      for(int i = 0; i < guess.length; i++) {
        // only check if the color is transparent
        if(letterBoxColor[i] == Colors.transparent) {
          currGuess = guess.substring(i, (i + 1));
          guessPos = currAnswer.indexOf(currGuess);
          if(guessPos >= 0) {
            letterBoxColor[i] = locationGuess;
            result[currGuess] = 3;
            currAnswer = removeCharacter(currAnswer, guessPos);
          }
          else {
            letterBoxColor[i] = wrongGuess;
            result[currGuess] = 0;
          }
        }
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(currLength, (index) {
        currGuess = "";
        // get the actual guess if the guess length > index
        if(guess.length > index) {
          currGuess = guess.substring(index, (index + 1));
        }
        return LetterBox(
          color: letterBoxColor[index],
          text: currGuess,
          width: width,
          height: width,
        );
      }),
    );
  }

  String removeCharacter(String word, int index) {
    return "${word.substring(0, index)} ${word.substring(index + 1)}";
  }
}
