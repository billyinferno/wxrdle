import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wxrdle/api/get_words_api.dart';
import 'package:wxrdle/model/word_list.dart';
import 'package:wxrdle/widgets/keyboard_button.dart';
import 'package:wxrdle/widgets/word_box.dart';
import 'globals/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Random _random = Random();
  final GetWordsAPI _getWordsAPI = GetWordsAPI();
  final List<String> _keyboardRow1 = ["Q","W","E","R","T","Y","U","I","O","P"];
  final List<String> _keyboardRow2 = ["A","S","D","F","G","H","J","K","L"];
  final List<String> _keyboardRow3 = ["Z","X","C","V","B","N","M"];
  late Map<int, Widget> _wordBox;
  late int _currentIndex;
  late String _answer;
  late String _guess;
  late int _maxLength;
  late int _maxAnswer;
  late WordList _wordList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // get the max length and answer from settings
    _maxLength = 5;
    _maxAnswer = 6;

    Future.microtask(() async {
      await resetGame().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: correctGuess,
        ),
      );
    }
    else {
      return _wordle();
    }
  }

  Widget _wordle() {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Wxrdle",
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_maxAnswer, (index) {
                  return _wordBox[index]!;
                }),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              height: 180,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(10, (index) {
                      return KeyboardButton(
                        char: _keyboardRow1[index],
                        onPress: ((value) {
                          // check if the current guess length < than max length
                          if(_guess.length < _maxLength) {
                            // debugPrint(value);
                            // set the current guess
                            _guess = _guess + value;
                            // now change the wordbox on current index
                            setState(() {
                              _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
                            });
                          }
                        })
                      );
                    }),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(9, (index) {
                      return KeyboardButton(
                        char: _keyboardRow2[index],
                        onPress: ((value) {
                          // check if the current guess length < than max length
                          if(_guess.length < _maxLength) {
                            // debugPrint(value);
                            // set the current guess
                            _guess = _guess + value;
                            // now change the wordbox on current index
                            setState(() {
                              _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
                            });
                          }
                        })
                      );
                    }),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: InkWell(
                            onTap: () {
                              debugPrint("Enter");
                              if(_guess.length == _maxLength) {
                                setState(() {                                
                                  // check the answer
                                  _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, checkAnswer: true, length: _maxLength,);

                                  // check if the answer correct or not?
                                  if(_answer == _guess) {
                                    // show popup box tell that you are win
                                    debugPrint("Win!");
                                  }
                                  else {
                                    // next current index
                                    if(_currentIndex < (_maxAnswer - 1)) {
                                      _currentIndex = _currentIndex + 1;
                                      // clear the guess
                                      _guess = "";
                                    }
                                    else {
                                      debugPrint("Game Over!");
                                    }
                                  }
                                }); 
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: buttonBackground,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              margin: const EdgeInsets.all(2),
                              child: const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "ENTER",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textColor
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...List.generate(7, (index) {
                        return KeyboardButton(
                          char: _keyboardRow3[index],
                          onPress: ((value) {
                            // check if the current guess length < than max length
                            if(_guess.length < _maxLength) {
                              // debugPrint(value);
                              // set the current guess
                              _guess = _guess + value;
                              // now change the wordbox on current index
                              setState(() {
                                _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
                              });
                            }
                          })
                        );
                      }),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: InkWell(
                            onTap: () {
                              debugPrint("Delete");
                              if(_guess.isNotEmpty) {
                                // debugPrint(value);
                                // set the current guess
                                _guess = _guess.substring(0, _guess.length - 1);
                                // now change the wordbox on current index
                                setState(() {
                                  _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: buttonBackground,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              margin: const EdgeInsets.all(2),
                              child: const Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  CupertinoIcons.delete_left
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Future<void> resetGame() async {
    await _getWordsFromAPI().then((value) {
      _wordList = value;

      _wordList.wordPages[0].wordList.shuffle();

      // get the word from API call
      _answer = _wordList.wordPages[0].wordList[0].word.toUpperCase();
      debugPrint(_answer);
      _guess = "";

      // start from index 0, if index already _maxAnswer we will need to finished the game
      _currentIndex = 0;

      // generate word box widget and put onto _wordBox
      _wordBox = {};
      for(int i=0; i<_maxAnswer; i++) {
        _wordBox[i] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
      }
    });
  }

  Future<WordList> _getWordsFromAPI() async {
    List<String> _alphabet = List.generate(26, (index) {
      return String.fromCharCode(97 + index);
    });
    
    String _firstChar;
    String _endChar;

    WordList _result = WordList(wordPages: []);

    while(_result.wordPages.isEmpty) {
      // shuffle the alphabet
      _alphabet.shuffle(_random);
      _firstChar = _alphabet[0];
      
      _alphabet.shuffle(_random);
      _endChar = _alphabet[0];
      
      await _getWordsAPI.getWords(
        length: _maxLength,
        startChar: _firstChar,
        endChar: _endChar,
      ).then((resp) {
        _result = resp;
      });
    }

    return _result;
  }
}