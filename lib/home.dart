import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wxrdle/api/get_words_api.dart';
import 'package:wxrdle/globals/colors.dart';
import 'package:wxrdle/model/answer_list.dart';
import 'package:wxrdle/model/word_list.dart';
import 'package:wxrdle/storage/local_box.dart';
import 'package:wxrdle/utils/show_alert_dialog.dart';
import 'package:wxrdle/widgets/keyboard_button.dart';
import 'package:wxrdle/widgets/selector_range.dart';
import 'package:wxrdle/widgets/word_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  final GetWordsAPI _getWordsAPI = GetWordsAPI();
  final Map<int, List<String>> _keyboardRow = {
    0:["Q","W","E","R","T","Y","U","I","O","P"],
    1:["A","S","D","F","G","H","J","K","L"],
    2:["Z","X","C","V","B","N","M"],
  };
  final Map<int, List<bool>> _keyboardState = {
    0:[true,true,true,true,true,true,true,true,true,true],
    1:[true,true,true,true,true,true,true,true,true],
    2:[true,true,true,true,true,true,true],
  };

  late Map<int, Widget> _wordBox;
  late int _currentIndex;
  late String _answer;
  late int _answerPoint;
  late int _pointGot;
  late int _currentPoint;
  late String _guess;
  late int _maxLength;
  late int _maxAnswer;
  late WordList _wordList;
  late String? _defHeadword;
  late String? _defPart;
  late String? _defMeaning;
  late String? _defUrl;
  late double _buttonWidth;
  late int _selectedMaxLength;
  late int _selectedMaxAnswer;

  late List<AnswerList> _answerList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // initialize answer list
    _answerList = [];

    // get the max length and answer from settings
    _maxLength = 5;
    _maxAnswer = 6;

    // initialize the current point as 0
    _currentPoint = 0;

    // initialize wordbox as empty
    _wordBox = {};

    Future.microtask(() async {
      await _getConfiguration();
      await _getCurrentPoint();
      await _getAnswerList();
      await resetGame().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    // calculate the button width
    _buttonWidth = ((MediaQuery.of(context).size.width - 20) / 7);
    if (_buttonWidth > 80) {
      _buttonWidth = 80;
    }

    // safearea hacks
    return Container(
      color: primaryBackground,
      child: SafeArea(
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
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  CupertinoIcons.arrow_counterclockwise
                ),
                onPressed: (() async {
                  // put the result as false
                  // generate the answer list and put on the answer list
                  AnswerList _answerData = AnswerList(answer: _answer, correct: false);
                  _answerList.add(_answerData);
                  await _putAnswerList();
    
                  showAlertDialog(
                    context: context,
                    title: "Skipped",
                    body: "Skipped answer is " + _answer,
                    headword: _defHeadword,
                    part: _defPart,
                    meaning: _defMeaning,
                    url: _defUrl,
                    callback: resetGame,
                    enableButton: _enableAllButton
                  ).then((value) async {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                }),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                const SizedBox(
                  height: 80,
                  child: DrawerHeader(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Configuration"
                  ),
                  onTap: (() async {
                    // debugPrint("Open configuration box");
                    Navigator.of(context).pop();
    
                    _selectedMaxLength = _maxLength;
                    _selectedMaxAnswer = _maxAnswer;
    
                    // show the dialog
                    await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: ((BuildContext context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    const Expanded(
                                      child: Text(
                                        "Configuration",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ),
                                    const SizedBox(width: 10,),
                                    IconButton(
                                      onPressed: (() {
                                        // close the pop up
                                        Navigator.of(context).pop();
                                      }),
                                      icon: const Icon(
                                        CupertinoIcons.clear,
                                        color: Colors.white,
                                      )
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                const Text("Max Length"),
                                SelectorRange(
                                  selected: _selectedMaxLength,
                                  length: 6,
                                  start: 5,
                                  onSelect: ((value) {
                                    debugPrint("Value pressed : " + value.toString());
                                    _selectedMaxLength = value;
                                  })
                                ),
                                const SizedBox(height: 20,),
                                const Text("Max Answer"),
                                SelectorRange(
                                  selected: _selectedMaxAnswer,
                                  length: 4,
                                  start: 4,
                                  onSelect: ((value) {
                                    debugPrint("Value pressed : " + value.toString());
                                    _selectedMaxAnswer = value;
                                  })
                                ),
                                const SizedBox(height: 20,),
                                Center(
                                  child: MaterialButton(
                                    onPressed: (() async {
                                      debugPrint("Set the max length " + _selectedMaxLength.toString() + " and max answer " + _selectedMaxAnswer.toString());
    
                                      _maxAnswer = _selectedMaxAnswer;
                                      _maxLength = _selectedMaxLength;
    
                                      await resetGame().then((_) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      });
    
                                      Navigator.of(context).pop();
                                    }),
                                    child: const Text("Apply"),
                                    color: correctGuess,
                                    minWidth: double.infinity,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
                ListTile(
                  title: const Text(
                    "History"
                  ),
                  onTap: (() {
                    // debugPrint("Open history box");
                    Navigator.of(context).pop();
    
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext contex) {
                        return AlertDialog(
                          title: const Text(
                            "History",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SizedBox(
                            height: 350,
                            width: 300,
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: List<Widget>.generate(_answerList.length, (index) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(child: Text(_answerList[index].answer)),
                                          Icon(
                                            (_answerList[index].correct ? CupertinoIcons.check_mark : CupertinoIcons.clear),
                                            color: (_answerList[index].correct ? correctGuess : Colors.red),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                MaterialButton(
                                  color: correctGuess,
                                  minWidth: double.infinity,
                                  child: const Text("OK"),
                                  onPressed: (() {
                                    Navigator.of(context).pop();
                                  })
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  }),
                ),
                ListTile(
                  title: const Text(
                    "About"
                  ),
                  onTap: (() async {
                    // debugPrint("Open history box");
                    Navigator.of(context).pop();
    
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            "About Wxrdle",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const Text("Copyright © - 2022 - Adi Martha"),
                                const Text("GNU GPL License v.3"),
                                const SizedBox(height: 10,),
                                InkWell(
                                  child: const Text(
                                    "https://github.com/billyinferno/wxrdle",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: (() {
                                    //launch('https://github.com/billyinferno/wxrdle', forceSafariVC: false, forceWebView: false);
                                  }),
                                ),
                                const SizedBox(height: 10,),
                                const Text(
                                  "Word provided by:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  child: const Text(
                                    "https://word.tips",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: (() {
                                    //launch('https://word.tips/', forceSafariVC: false, forceWebView: false);
                                  }),
                                ),
                                const SizedBox(height: 10,),
                                const Text(
                                  "Definition provided by:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  child: const Text(
                                    "https://yourdictionary.com",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: (() {
                                    //launch('https://yourdictionary.com/', forceSafariVC: false, forceWebView: false);
                                  }),
                                ),
                                const SizedBox(height: 10,),
                                MaterialButton(
                                  color: correctGuess,
                                  minWidth: double.infinity,
                                  child: const Text("OK"),
                                  onPressed: (() {
                                    Navigator.of(context).pop();
                                  }),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  }),
                )
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ...List.generate(_maxAnswer, (index) {
                        return _wordBox[index]!;
                      }),
                      const SizedBox(height: 5,),
                      Text(
                        _currentPoint.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 160,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(10, (index) {
                        return KeyboardButton(
                          enabled: _keyboardState[0]![index],
                          char: _keyboardRow[0]![index],
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
                          char: _keyboardRow[1]![index],
                          enabled: _keyboardState[1]![index],
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
                        SizedBox(
                          height: 50,
                          width: _buttonWidth,
                          child: InkWell(
                            onTap: () async {
                              // debugPrint("Enter");
                              if(_guess.length == _maxLength) {
                                // check the answer
                                _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, checkAnswer: true, length: _maxLength,);
    
                                // loop thru the guess and see if there are character that not on the answer
                                String _currGuess;
                                int _currPos;
                                for(int i = 0; i < _guess.length; i++) {
                                  _currGuess = _guess.substring(i, i+1);
                                  _currPos = _answer.indexOf(_currGuess);
                                  if(_currPos < 0) {
                                    // wrong answer disabled button
                                    _disableButton(_currGuess);
                                  }
                                }
    
                                // check if the answer correct or not?
                                if(_answer == _guess) {
                                  // add point
                                  _pointGot = (_answerPoint * (_maxAnswer - _currentIndex));
                                  _currentPoint = _currentPoint + _pointGot;
    
                                  // stored the current point to the box
                                  await LocalBox.put(key: 'current_point', value: _currentPoint);
    
                                  // generate the answer list and put on the answer list
                                  AnswerList _answerData = AnswerList(answer: _answer, correct: true);
                                  _answerList.add(_answerData);
                                  await _putAnswerList();
    
                                  // show dialog, and reset game
                                  showAlertDialog(
                                    context: context,
                                    title: "You Win",
                                    body: "Congratulations, correct answer is " + _answer + " with " + _pointGot.toString() + " points.",
                                    headword: _defHeadword,
                                    part: _defPart,
                                    meaning: _defMeaning,
                                    url: _defUrl,
                                    callback: resetGame,
                                    enableButton: _enableAllButton
                                  ).then((value) {
                                    // just set state
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  });
                                }
                                else {
                                  // next current index
                                  if(_currentIndex < (_maxAnswer - 1)) {
                                    setState(() {
                                      // next index
                                      _currentIndex = _currentIndex + 1;
     
                                      // clear the guess
                                      _guess = "";
                                    });
                                  }
                                  else {
                                    // generate the answer list and put on the answer list
                                    AnswerList _answerData = AnswerList(answer: _answer, correct: false);
                                    _answerList.add(_answerData);
                                    await _putAnswerList();
    
                                    showAlertDialog(
                                      context: context,
                                      title: "You Lose",
                                      body: "Try again next time, correct answer is " + _answer,
                                      headword: _defHeadword,
                                      part: _defPart,
                                      meaning: _defMeaning,
                                      url: _defUrl,
                                      callback: resetGame,
                                      enableButton: _enableAllButton
                                    ).then((value) {
                                      // just set state
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    });
                                  }
                                }
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
                        ...List.generate(7, (index) {
                          return KeyboardButton(
                            char: _keyboardRow[2]![index],
                            enabled: _keyboardState[2]![index],
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
                        SizedBox(
                          height: 50,
                          width: _buttonWidth,
                          child: InkWell(
                            onTap: () {
                              // debugPrint("Delete");
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
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Word is provided by https://word.tips/ - https://yourdictionary.com/",
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _disableButton(String char) {
    // loop in keyboardRow to get where is the char location
    for(int i = 0; i <= 2; i++) {
      for(int j = 0; j < _keyboardRow[i]!.length; j++) {
        // check if the char is the same or not
        if(_keyboardRow[i]![j] == char) {
          // disable this button
          _keyboardState[i]![j] = false;
        }
      }
    }
  }

  void _enableAllButton() {
    for(int i = 0; i <= 2; i++) {
      for(int j = 0; j < _keyboardRow[i]!.length; j++) {
        _keyboardState[i]![j] = true;
      }
    }
  }

  Future<void> _getConfiguration() async {
    int? _currentMaxLength;
    int? _currentMaxAnswer;

    _currentMaxLength = LocalBox.get(key: 'max_length');
    _currentMaxAnswer = LocalBox.get(key: 'max_answer');

    if(_currentMaxLength == null) {
      LocalBox.put(key: 'max_length', value: _maxLength);
    }
    else {
      _maxLength = _currentMaxLength;
    }

    if(_currentMaxAnswer == null) {
      LocalBox.put(key: 'max_answer', value: _maxAnswer);
    }
    else {
      _maxAnswer = _currentMaxAnswer;
    }
  }

  Future<void> _getCurrentPoint() async {
    int? _currentPointOnBox;

    _currentPointOnBox = LocalBox.get(key: 'current_point');
    // check if _currentPointOnBox is null or not?
    if(_currentPointOnBox == null) {
      // put the current point as 0 on the box
      LocalBox.put(key: 'current_point', value: 0);
    }
    else {
      // put the current point on box to _currentPoint
      _currentPoint = _currentPointOnBox;
    }
  }

  Future<void> _getAnswerList() async {
    dynamic _boxAnswerList;

    _boxAnswerList = LocalBox.get(key: 'answer_list');
    // check if this is not null?
    if(_boxAnswerList != null) {
      // this is list of answer, so convert this dynamic to list of string
      List<String> _currentAnswerList = List<String>.from(_boxAnswerList);
      for (String _currentList in _currentAnswerList) {
        // convert this to answer list model
        AnswerList _answer = AnswerList.fromJson(jsonDecode(_currentList));
        // add this to the answer list
        _answerList.add(_answer);
      }
    }
  }

  Future<void> _putAnswerList() async {
    List<String> _listOfAnswer = [];

    // loop thru the answer list
    for (AnswerList _answerData in _answerList) {
      _listOfAnswer.add(jsonEncode(_answerData.toJson()));
    }

    // put on the box
    await LocalBox.put(key: 'answer_list', value: _listOfAnswer);
  }

  Future<void> resetGame() async {
    await _getWordsFromAPI().then((value) async {
      _wordList = value;

      _wordList.wordPages[0].wordList.shuffle();

      // get the word from API call
      _answer = _wordList.wordPages[0].wordList[0].word.toUpperCase();
      
      // calculate the answer point based on the length of answer
      _answerPoint = _wordList.wordPages[0].wordList[0].points ~/ _maxAnswer;
      // check if _answerPoint is below 1
      if(_answerPoint <= 0) {
        _answerPoint = 1;
      }

      _guess = "";

      // get the definition
      await _getWordsAPI.getDefinition(word: _wordList.wordPages[0].wordList[0].word).then((def) {
        if(def.data.isNotEmpty) {
          _defHeadword = def.data[0].headword;
          _defPart = def.data[0].pos[0].poPart;
          _defMeaning = def.data[0].pos[0].senses[0].txt;
          _defUrl = def.data[0].audio;
        }
        else {
          _defHeadword = null;
          _defPart = null;
          _defMeaning = null;
          _defUrl = null;
        }
      });

      // start from index 0, if index already _maxAnswer we will need to finished the game
      _currentIndex = 0;

      // generate word box widget and put onto _wordBox
      _wordBox.clear();
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