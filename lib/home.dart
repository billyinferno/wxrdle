import 'dart:convert';
import 'dart:math';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wxrdle/api/get_words_api.dart';
import 'package:wxrdle/globals/colors.dart';
import 'package:wxrdle/globals/url.dart';
import 'package:wxrdle/model/answer_list.dart';
import 'package:wxrdle/model/definition_model.dart';
import 'package:wxrdle/model/save_state_model.dart';
import 'package:wxrdle/model/word_list.dart';
import 'package:wxrdle/storage/local_box.dart';
import 'package:wxrdle/utils/show_alert_dialog.dart';
import 'package:wxrdle/utils/show_loader_dialog.dart';
import 'package:wxrdle/widgets/game_selector.dart';
import 'package:wxrdle/widgets/keyboard_button.dart';
import 'package:wxrdle/widgets/selector_range.dart';
import 'package:wxrdle/widgets/word_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({ super.key });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardNode = FocusNode();
  final Random _random = Random();
  final GetWordsAPI _getWordsAPI = GetWordsAPI();
  final Map<int, List<String>> _keyboardRow = {
    0:["Q","W","E","R","T","Y","U","I","O","P"],
    1:["A","S","D","F","G","H","J","K","L"],
    2:["Z","X","C","V","B","N","M"],
  };
  final Map<int, List<int>> _keyboardState = {
    0:[1,1,1,1,1,1,1,1,1,1],
    1:[1,1,1,1,1,1,1,1,1],
    2:[1,1,1,1,1,1,1],
  };
  final Map<int, String> _gameType = {
    0:"Easy Mode",
    1:"Continues",
    2:"Survival",
  };
  final Map<int, String> _dictCheck = {
    0:"No",
    1:"Yes",
  };
  final Map<int, int> _gameHighScore = {
    0:0,
    1:0,
    2:0,
  };

  late Map<int, Widget> _wordBox;
  late int _currentIndex;
  late int _currentGameMode;
  late int _currentDictCheck;
  late int _totalHints;
  late int _totalStreak;
  late String _currentWrongGuess;
  late String _answer;
  late int _answerPoint;
  late int _pointGot;
  late int _currentPoint;
  late String _guess;
  late int _maxLength;
  late int _maxAnswer;
  late String? _defHeadword;
  late String? _defPart;
  late String? _defMeaning;
  late String? _defUrl;
  late double _buttonWidth;
  late int _selectedMaxLength;
  late int _selectedMaxAnswer;
  late int _selectedGameMode;
  late int _selectedDictCheck;
  late bool _isCheckFailed;
  late bool _prevKeyPressBackspace;

  late List<AnswerList> _answerList;
  late Map<int, AnswerList> _currentAnswerList;
  late Map<String, int> _keyboardResult;
  bool _isLoading = true;
  bool _errorGetWord = false;

  @override
  void initState() {
    super.initState();

    // assuming that backspace not yet pressed
    _prevKeyPressBackspace = false;

    // assuming current index is 0
    _currentIndex = 0;

    // assuming that the current game mode is easy mode
    _currentGameMode = 0;

    // assuming that we will never perform dictionary check
    _currentDictCheck = 0;

    // default total hints is 5
    _totalHints = 5;
    _totalStreak = 0;

    // check is not yet failed
    _isCheckFailed = false;
    _currentWrongGuess = "";

    // initialize answer list
    _answerList = [];
    _currentAnswerList = {};

    // get the max length and answer from settings
    _maxLength = 5;
    _maxAnswer = 6;

    // initialize the current point as 0
    _currentPoint = 0;

    // initialize wordbox as empty
    _wordBox = {};

    Future.microtask(() async {
      await _getConfiguration();
      await _getAnswerList();
      await _checkState();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _keyboardNode.dispose();
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
      if(_errorGetWord) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Container(
                height: 200,
                margin: const EdgeInsets.all(20),
                color: Colors.grey[800],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Colors.red,
                      size: 35,
                    ),
                    const SizedBox(height: 10,),
                    const Text("Error when get words from API."),
                    const Text("Please wait a moment, and try refresh again"),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: MaterialButton(
                        color: correctGuess,
                        minWidth: double.infinity,
                        onPressed: () async {
                          // save the state as reset
                          await _saveState(isReset: true);
            
                          await _resetGame().then((value) {
                            if(value) {
                              _enableAllButton();
                            }
                          });
                        },
                        child: const Text("Refresh"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      else {
        return _wordle();
      }
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
              badges.Badge(
                badgeStyle: badges.BadgeStyle(badgeColor: Colors.green[800]!),
                position: badges.BadgePosition.topEnd(top: 5, end: 3),
                badgeContent: Text(_totalHints.toString()),
                showBadge: (_totalHints > 0),
                child: InkWell(
                  onTap: (() async {
                    // check if we still have hints or not
                    if(_totalHints <= 0) {
                      return;
                    }

                    // get the random number from 0 - maxLength
                    List<int> randomIndexList = List<int>.generate(_maxLength, (index) => index);
                    randomIndexList.shuffle();
                    String hint = (_answer.substring(randomIndexList[0], randomIndexList[0] + 1));

                    // once got the hints show the dialog
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                "Hint",
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
                        content: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: correctGuess,
                                  borderRadius: BorderRadius.circular(150)
                                ),
                                child: Center(
                                  child: Text(
                                    hint,
                                    style: const TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Text("At position ${randomIndexList[0] + 1}"),
                            ],
                          ),
                        ),
                      );
                    });

                    setState(() {
                      _totalHints = _totalHints - 1;
                    });
                    await LocalBox.put(key: 'total_hints', value: _totalHints);
                  }),
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    // color: Colors.purple,
                    child: const Icon(
                      CupertinoIcons.lightbulb
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.arrow_counterclockwise
                ),
                onPressed: (() async {
                  // update the score
                  _updateScore(false);

                  // put the result as false
                  // generate the answer list and put on the answer list
                  AnswerList answerData = AnswerList(answer: _answer, correct: false);
                  _answerList.add(answerData);
                  await _putAnswerList();

                  // save the state as reset
                  await _saveState(isReset: true);

                  if (mounted) {
                    showAlertDialog(
                      context: context,
                      title: "Skipped",
                      body: "Skipped answer is $_answer",
                      headword: _defHeadword,
                      part: _defPart,
                      meaning: _defMeaning,
                      url: _defUrl,
                      callback: _resetGame,
                      enableButton: _enableAllButton
                    ).then((value) async {
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  }
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
                    _selectedGameMode = _currentGameMode;
                    _selectedDictCheck = _currentDictCheck;
    
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
                                    _selectedMaxAnswer = value;
                                  })
                                ),
                                const SizedBox(height: 20,),
                                const Text("Game Type"),
                                GameSelector(
                                  selectedGameMode: _selectedGameMode,
                                  gameType: _gameType,
                                  onSelect: (value) {
                                    _selectedGameMode = value;
                                  }
                                ),
                                const SizedBox(height: 10,),
                                const Text("Word Check"),
                                GameSelector(
                                  selectedGameMode: _selectedDictCheck,
                                  gameType: _dictCheck,
                                  onSelect: (value) {
                                    _selectedDictCheck = value;
                                  }
                                ),
                                const SizedBox(height: 20,),
                                Center(
                                  child: MaterialButton(
                                    onPressed: (() async {    
                                      _maxAnswer = _selectedMaxAnswer;
                                      _maxLength = _selectedMaxLength;
                                      _currentGameMode = _selectedGameMode;
                                      _currentDictCheck = _selectedDictCheck;

                                      // if user press apply, we will assuming all will be reset
                                      // so reset the current point into 0 again
                                      _currentPoint = 0;

                                      // save the configuration
                                      await _saveConfiguration();

                                      // save the state as reset
                                      await _saveState(isReset: true);
    
                                      await _resetGame().then((_) {
                                        // enable all button before we refresh the state
                                        _enableAllButton();

                                        setState(() {
                                          _isLoading = false;
                                        });
                                      });

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    }),
                                    color: correctGuess,
                                    minWidth: double.infinity,
                                    child: const Text("Apply"),
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
                                  onPressed: (() {
                                    Navigator.of(context).pop();
                                  }),
                                  child: const Text("OK")
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
                    "High Score"
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
                            "High Score",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ...List<Widget>.generate(_gameHighScore.length, (index) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(child: Text(_gameType[index]!)),
                                      const SizedBox(width: 10,),
                                      Text(
                                        _gameHighScore[index]!.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: correctGuess,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 10,),
                                MaterialButton(
                                  color: correctGuess,
                                  minWidth: double.infinity,
                                  onPressed: (() {
                                    Navigator.of(context).pop();
                                  }),
                                  child: const Text("OK")
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
                                Text("Version ${URLConfig.version}"),
                                const SizedBox(height: 10,),
                                const Text("Copyright © - 2022 - Adi Martha"),
                                const Text("GNU GPL License v.3"),
                                const SizedBox(height: 10,),
                                InkWell(
                                  onTap: (() {
                                    //launch('https://github.com/billyinferno/wxrdle', forceSafariVC: false, forceWebView: false);
                                  }),
                                  child: const Text(
                                    "https://github.com/billyinferno/wxrdle",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 12,
                                    ),
                                  ),
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
                                  onTap: (() {
                                    //launch('https://word.tips/', forceSafariVC: false, forceWebView: false);
                                  }),
                                  child: const Text(
                                    "https://word.tips",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 12,
                                    ),
                                  ),
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
                                  onTap: (() {
                                    //launch('https://yourdictionary.com/', forceSafariVC: false, forceWebView: false);
                                  }),
                                  child: const Text(
                                    "https://yourdictionary.com",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                MaterialButton(
                                  color: correctGuess,
                                  minWidth: double.infinity,
                                  onPressed: (() {
                                    Navigator.of(context).pop();
                                  }),
                                  child: const Text("OK"),
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
          body: KeyboardListener(
            autofocus: true,
            focusNode: _keyboardNode,
            onKeyEvent: ((val) async {
              if(val.logicalKey == LogicalKeyboardKey.backspace) {
                // debouncing for backspace, as it registered as 2 keystroke instead of 1
                if (!_prevKeyPressBackspace) {
                  if(_guess.isNotEmpty) {
                    // set the current guess
                    _guess = _guess.substring(0, _guess.length - 1);
                    // now change the wordbox on current index
                    setState(() {
                      _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
                    });
                  }
                  _prevKeyPressBackspace = true;
                }
                else {
                  _prevKeyPressBackspace = false;
                }
              }
              else if(val.logicalKey == LogicalKeyboardKey.enter) {
                await _keyboardEnter();
              }
              else {
                if(val.character != null) {
                  // check if the current guess length < than max length
                  if(_guess.length < _maxLength) {
                    // debugPrint(value);
                    // set the current guess
                    _guess = _guess + val.character!.toUpperCase();
                    // now change the wordbox on current index
                    setState(() {
                      _wordBox[_currentIndex] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
                    });
                  }
                }
              }
            }),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(10, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                        decoration: BoxDecoration(
                          color: ((index + 1) <= _totalStreak ? correctGuess : Colors.transparent),
                          border: Border.all(color: Colors.grey[900]!)
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 5,),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _currentPoint.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: (_currentPoint == _gameHighScore[_currentGameMode]! ? correctGuess : locationGuess),
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              "(${_gameHighScore[_currentGameMode]!})",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: correctGuess,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Visibility(
                          visible: (_currentDictCheck == 1 && _isCheckFailed),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            color: Colors.red,
                            child: Text(
                              "$_currentWrongGuess is not found in dictionary",
                              style: const TextStyle(
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
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
                                await _keyboardEnter();
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
                                    CupertinoIcons.check_mark,
                                    size: 15,
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
                                    CupertinoIcons.delete_left,
                                    size: 15,
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
                const SizedBox(height: 30,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _checkAnswer() async {
    bool checkFailed = false;

    if(_currentDictCheck == 1) {
      // perform a dictionary check first
      if(_answer != _guess) {
        // we only need to perform check when the answer is not the same
        showLoaderDialog(context);
        await _getWordsAPI.searchWords(
          word: _guess
        ).then((resp) {
          checkFailed = resp;
        }).whenComplete(() {
          if (mounted) {
            // remove loader when complete
            Navigator.of(context).pop();
          }
        });
      }
    }

    if(checkFailed) {
      return false;
    }

    // check the answer
    _wordBox[_currentIndex] = WordBox(
      answer: _answer,
      guess: _guess,
      checkAnswer: true,
      length: _maxLength,
    );

    AnswerList currentAnswerData = AnswerList(answer: _guess, correct: (_answer == _guess));
    _currentAnswerList[_currentIndex] = currentAnswerData;

    String tempAnswer = _answer;
    String currGuess = "";
    String currAnswer = "";
    int guessPos = -1;

    // map the keyboard result with the guess
    _keyboardResult = {};
    for(int i = 0; i < _guess.length; i++) {
      _keyboardResult[_guess.substring(i, (i+1))] = -1;
    }

    for(int i = 0; i < _guess.length; i++) {
      currGuess = _guess.substring(i, (i + 1));
      currAnswer = _answer.substring(i, (i + 1));
      if(currGuess == currAnswer) {
        _keyboardResult[currGuess] = 2;
        tempAnswer = "${tempAnswer.substring(0, i)} ${tempAnswer.substring(i + 1)}";
      }
    }

    // now scan thru all the guess on the answer
    for(int i = 0; i < _guess.length; i++) {
      // only check if the color is transparent
      currGuess = _guess.substring(i, (i + 1));
      if(_keyboardResult[currGuess] == -1) {
        guessPos = tempAnswer.indexOf(currGuess);
        if(guessPos >= 0) {
          _keyboardResult[currGuess] = 3;
          tempAnswer = "${tempAnswer.substring(0, guessPos)} ${tempAnswer.substring(guessPos + 1)}";
        }
        else {
          _keyboardResult[currGuess] = 0;
        }
      }
    }

    return true;
  }

  void _disableButton(String char, int status) {
    // loop in keyboardRow to get where is the char location
    for(int i = 0; i <= 2; i++) {
      for(int j = 0; j < _keyboardRow[i]!.length; j++) {
        // check if the char is the same or not
        if(_keyboardRow[i]![j] == char) {
          // disable this button
          _keyboardState[i]![j] = status;
        }
      }
    }
  }

  void _enableAllButton() {
    for(int i = 0; i <= 2; i++) {
      for(int j = 0; j < _keyboardRow[i]!.length; j++) {
        _keyboardState[i]![j] = 1;
      }
    }
  }

  // bool _checkButton(String char) {
  //   // loop in keyboardRow to get where is the char location
  //   for(int i = 0; i <= 2; i++) {
  //     for(int j = 0; j < _keyboardRow[i]!.length; j++) {
  //       // check if the char is the same or not
  //       if(_keyboardRow[i]![j] == char) {
  //         // disable this button
  //         if (_keyboardState[i]![j] > 0) {
  //           return true;
  //         }
  //         return false;
  //       }
  //     }
  //   }
  //   // other than the one we put on the keyboard row it means
  //   // that the character is invalid.
  //   return false;
  // }

  Future<void> _saveConfiguration() async {
    await LocalBox.put(key: 'max_length', value: _maxLength);
    await LocalBox.put(key: 'max_answer', value: _maxAnswer);
    await LocalBox.put(key: 'game_mode', value: _currentGameMode);
    await LocalBox.put(key: 'dict_check', value: _currentDictCheck);
    await LocalBox.put(key: 'current_point', value: _currentPoint);
  }

  Future<void> _getConfiguration() async {
    int? currentPointOnBox;
    int? currentMaxLength;
    int? currentMaxAnswer;
    int? currentConfigGameMode;
    int? currentConfigDictCheck;
    int? currentHighScore;
    int? currentTotalHints;
    int? currentTotalStreak;

    currentPointOnBox = LocalBox.get(key: 'current_point');
    currentMaxLength = LocalBox.get(key: 'max_length');
    currentMaxAnswer = LocalBox.get(key: 'max_answer');
    currentConfigGameMode = LocalBox.get(key: 'game_mode');
    currentConfigDictCheck = LocalBox.get(key: 'dict_check');
    currentTotalHints = LocalBox.get(key: 'total_hints');
    currentTotalStreak = LocalBox.get(key: 'total_streak');

    // check if _currentPointOnBox is null or not?
    if(currentPointOnBox == null) {
      // put the current point as 0 on the box
      await LocalBox.put(key: 'current_point', value: 0);
    }
    else {
      // put the current point on box to _currentPoint
      _currentPoint = currentPointOnBox;
    }

    if(currentMaxLength == null) {
      await LocalBox.put(key: 'max_length', value: _maxLength);
    }
    else {
      _maxLength = currentMaxLength;
    }

    if(currentMaxAnswer == null) {
      await LocalBox.put(key: 'max_answer', value: _maxAnswer);
    }
    else {
      _maxAnswer = currentMaxAnswer;
    }

    if(currentConfigGameMode == null) {
      await LocalBox.put(key: 'game_mode', value: _currentGameMode);
    }
    else {
      _currentGameMode = currentConfigGameMode;
    }

    if(currentConfigDictCheck == null) {
      await LocalBox.put(key: 'game_mode', value: _currentDictCheck);
    }
    else {
      _currentDictCheck = currentConfigDictCheck;
    }

    // get high score for all mode
    // mode - 0
    currentHighScore = LocalBox.get(key: 'high_score_0');
    if(currentHighScore == null) {
      await LocalBox.put(key: 'high_score_0', value: _gameHighScore[0]);
    }
    else {
      _gameHighScore[0] = currentHighScore;
    }
    // mode - 1
    currentHighScore = LocalBox.get(key: 'high_score_1');
    if(currentHighScore == null) {
      await LocalBox.put(key: 'high_score_1', value: _gameHighScore[1]);
    }
    else {
      _gameHighScore[1] = currentHighScore;
    }
    // mode - 2
    currentHighScore = LocalBox.get(key: 'high_score_2');
    if(currentHighScore == null) {
      await LocalBox.put(key: 'high_score_2', value: _gameHighScore[2]);
    }
    else {
      _gameHighScore[2] = currentHighScore;
    }

    // get current total hints available for user
    if(currentTotalHints == null) {
      // default hints is 5
      await LocalBox.put(key: 'total_hints', value: 5);
      _totalHints = 5;
    }
    else {
      // put the current point on box to _currentPoint
      _totalHints = currentTotalHints;
    }

    // get current total streak of user
    if(currentTotalStreak == null) {
      // default hints is 5
      await LocalBox.put(key: 'total_streak', value: 0);
    }
    else {
      // put the current point on box to _currentPoint
      _totalStreak = currentTotalStreak;
    }
  }

  Future<void> _getAnswerList() async {
    dynamic boxAnswerList;

    boxAnswerList = LocalBox.get(key: 'answer_list');
    // check if this is not null?
    if(boxAnswerList != null) {
      // this is list of answer, so convert this dynamic to list of string
      List<String> currAnswerList = List<String>.from(boxAnswerList);
      for (String currentList in currAnswerList) {
        // convert this to answer list model
        AnswerList answer = AnswerList.fromJson(jsonDecode(currentList));
        // add this to the answer list
        _answerList.add(answer);
      }
    }
  }

  Future<void> _putAnswerList() async {
    List<String> listOfAnswer = [];

    // loop thru the answer list
    for (AnswerList answerData in _answerList) {
      listOfAnswer.add(jsonEncode(answerData.toJson()));
    }

    // put on the box
    await LocalBox.put(key: 'answer_list', value: listOfAnswer);
  }

  Future<bool> _resetGame() async {
    try {
      await _getWordsFromAPI().then((_) async {
        // reset guess, keyboard result, and current answer list
        _guess = "";
        _keyboardResult = {};
        _currentAnswerList = {};

        // start from index 0, if index already _maxAnswer we will need to finished the game
        _currentIndex = 0;

        // generate word box widget and put onto _wordBox
        _wordBox.clear();
        for(int i=0; i<_maxAnswer; i++) {
          _wordBox[i] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
        }
      });

      // set the error get word into false, since we already got word we need to play
      _errorGetWord = false;
      return true;
    }
    catch(e) {
      debugPrint("⚠️ $e");
      // unable to get word from API showed the error message
      _errorGetWord = true;
      return false;
    }
  }

  Future<void> _getWordsFromAPI() async {
    List<String> alphabet = List.generate(26, (index) {
      return String.fromCharCode(97 + index);
    });

    bool wordFind = false;
    int tries = 0;
    int index = 0;
    
    String firstChar;
    String endChar;

    WordList wordList = WordList(wordPages: []);

    // default the definition to null
    _defHeadword = null;
    _defPart = null;
    _defMeaning = null;
    _defUrl = null;

    // true to find the word and definition at max 3 times
    while (!wordFind && tries < 5) {
      while(wordList.wordPages.isEmpty) {
        // shuffle the alphabet
        alphabet.shuffle(_random);
        firstChar = alphabet[0];
        
        alphabet.shuffle(_random);
        endChar = alphabet[0];

        await _getWordsAPI.getWords(
          length: _maxLength,
          startChar: firstChar,
          endChar: endChar,
        ).then((resp) {
          wordList = resp;
        }).onError((error, stackTrace) {
          debugPrint("Error:${error.toString()}");
          debugPrintStack(stackTrace: stackTrace);
          throw Exception("Error when get words from API");
        },);
      }

      // already got the word list, now we try to find the definition
      wordList.wordPages[0].wordList.shuffle();

      // get the first word from the word list
      _answer = wordList.wordPages[0].wordList[index].word.toUpperCase();
        
      // calculate the answer point based on the length of answer
      _answerPoint = wordList.wordPages[0].wordList[index].points ~/ _maxAnswer;
      // check if _answerPoint is below 1
      if(_answerPoint <= 0) {
        _answerPoint = 1;
      }

      // now try to get the definition of this word
      await _getWordsAPI.getDefinition(word: _answer.toLowerCase()).then((def) {
        if(def.data.isNotEmpty) {
          _defHeadword = def.data[0].headword;
          _defPart = def.data[0].pos[0].poPart;
          _defMeaning = "";
          for (Sense senses in def.data[0].pos[0].senses) {
            if (senses.txt != null) {
              if(senses.txt!.isNotEmpty) {
                _defMeaning = senses.txt;
                break;
              }
            }
          }
          _defUrl = def.data[0].audio;

          // we find both word and the definition
          wordFind = true;
        }
        else {
          // next index
          index = index + 1;

          // check if index already more than wordlist length?
          if (index >= (wordList.wordPages[0].wordList.length - 1)) {
            // clear the word list so we will get a new word
            wordList.wordPages.clear();

            // reset back index to 0
            index = 0;
          }
        }
      }).onError((error, stackTrace) {
        debugPrint("Error:${error.toString()}");
        debugPrintStack(stackTrace: stackTrace);
        throw Exception("Error when get definition from API");
      },);

      // add tries
      tries = tries + 1;
    }
  }

  Future<void> _checkState() async {
    await _loadState().then((res) async {
      if(res) {
        // this means that the game already have previous state
        debugPrint("🔃 Load previous state");
        setState(() {
          _isLoading = false;
        });
      }
      else {
        // save the state as reset
        await _saveState(isReset: true);

        await _resetGame().then((_) {
          // ensure to enable all the button before we refresh the state
          _enableAllButton();

          // refresh the application state
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  Future<bool> _loadState() async {
    // load should be only performed when we first load the app
    // otherwise we will just perform save state.
    // in case the savestate is null, then no need to perform anything.
    String? saveString = LocalBox.get(key: 'save_state');
    if(saveString != null) {
      // save string is not null, means we already have save state
      // parse this save string as SaveStateModel
      SaveStateModel save = SaveStateModel.fromJson(jsonDecode(saveString));
      
      // we got the save state, now we need to change the current index, etc.
      _currentIndex = save.currentIndex;

      // set the answer to the one that we put on the save state
      _answer = save.answer;
      _answerPoint = save.answerPoints;

      // set the definition
      _defHeadword = save.defHeadword;
      _defMeaning = save.defMeaning;
      _defPart = save.defPart;
      _defUrl = save.defUrl;

      _guess = "";
      _keyboardResult = {};
      _currentAnswerList = {};

      // then we need to change the keyboard state
      for (KeyboardMap kMap in save.keyboardMap) {
        _keyboardState[kMap.id] = kMap.map;
        for(int i = 0; i < _keyboardRow[kMap.id]!.length; i++) {
          _keyboardResult[_keyboardRow[kMap.id]![i]] = kMap.map[i];
        }
      }

      // generate word box widget and put onto _wordBox
      _wordBox.clear();
      for(int i=0; i<_maxAnswer; i++) {
        _wordBox[i] = WordBox(answer: _answer, guess: _guess, length: _maxLength,);
      }

      // then after that we need to generate a correct word box for each box
      // that already answered
      int i = 0;
      for (SaveAnswerList ans in save.answerList) {
        _wordBox[i] = WordBox(answer: save.answer, guess: ans.answer, checkAnswer: true, length: _maxLength,);
        _currentAnswerList[i] = AnswerList(answer: ans.answer, correct: ans.result);
        i = i + 1;
      }

      return true;
    }
    else {
      return false;
    }
  }

  Future<void> _saveState({bool? isReset}) async {
    // check if this is reset or not?
    // if reset, then we just stored null on the storage
    bool isBeingReset = (isReset ?? false);

    if(isBeingReset) {
      await LocalBox.put(key: 'save_state', value: null);
    }
    else {
      List<KeyboardMap> kMap = [];

      // loop thru _keyboardState
      _keyboardState.forEach((key, value) {
        kMap.add(KeyboardMap(id: key, map: _keyboardState[key]!));
      });

      // loop thru current answer list
      List<SaveAnswerList> sAnswer = [];
      _currentAnswerList.forEach((key, value) {
        sAnswer.add(SaveAnswerList(answer: _currentAnswerList[key]!.answer, result: _currentAnswerList[key]!.correct));
      });

      // generate the save state for this
      SaveStateModel saveState = SaveStateModel(
        currentIndex: (_currentIndex + 1),
        answer: _answer,
        answerPoints: _answerPoint,
        answerList: sAnswer,
        defHeadword: _defHeadword,
        defMeaning: _defMeaning,
        defPart: _defPart,
        defUrl: _defUrl,
        keyboardMap: kMap
      );

      // save to local storage
      await LocalBox.put(key: 'save_state', value: jsonEncode(saveState.toJson()));
    }
  }

  void _updateScore(bool isWin) async {
    int currentHighScore = _gameHighScore[_currentGameMode]!;

    if(!isWin) {
      // check the game mode
      if(_currentGameMode == 1) {
        // this is continues so we will minus the currentPoint with answerPoint
        _currentPoint = _currentPoint - _answerPoint;
      }
      else if(_currentGameMode == 2) {
        // reset the current point into 0
        _currentPoint = 0;
      }

      // save the current point to avoid user to restart to restore the current point1
      await LocalBox.put(key: 'current_point', value: _currentPoint);
    }

    // check if current point more than high score or not?
    // if more then save the current point
    if(_currentPoint > currentHighScore) {
      // put this on the local storage
      _gameHighScore[_currentGameMode] = _currentPoint;
      await LocalBox.put(key: 'high_score_$_currentGameMode', value: _currentPoint);
    }
  }

  Future<void> _keyboardEnter() async {
    if(_guess.length == _maxLength) {
    _isCheckFailed = false;
    await _checkAnswer().then((result) async {
      // check whether the answer given is acceptable or not?
      if(!result) {
        setState(() {
          _currentWrongGuess = _guess;
          _isCheckFailed = true;
        });
      }
      else {
        // answer acceptable, perform the action
        _keyboardResult.forEach((char, status) {
          _disableButton(char, status);
        });

        // save state once we add the current answer list and update the keyboard state
        await _saveState();

        // check if the answer correct or not?
        if(_answer == _guess) {
          // add point
          _pointGot = (_answerPoint * (_maxAnswer - _currentIndex));
          _currentPoint = _currentPoint + _pointGot;

          // stored the current point to the box
          await LocalBox.put(key: 'current_point', value: _currentPoint);

          // add total streak
          _totalStreak = _totalStreak + 1;
          // check if _totalStreak already 10
          if(_totalStreak >= 10) {
            // add 1 hints
            _totalHints = _totalHints + 1;
            await LocalBox.put(key: 'total_hints', value: _totalHints);

            // reset back total streak to 0
            _totalStreak = 0;
          }
          await LocalBox.put(key: 'total_streak', value: _totalStreak);

          // update the score
          _updateScore(true);

          // generate the answer list and put on the answer list
          AnswerList answerData = AnswerList(answer: _answer, correct: true);
          _answerList.add(answerData);
          await _putAnswerList();

          // save the state as reset
          await _saveState(isReset: true);

          // show dialog, and reset game
          if (mounted) {
            showAlertDialog(
              context: context,
              title: "You Win",
              body: "Congratulations, correct answer is $_answer with $_pointGot points.",
              headword: _defHeadword,
              part: _defPart,
              meaning: _defMeaning,
              url: _defUrl,
              callback: _resetGame,
              enableButton: _enableAllButton
            ).then((value) {
              // just set state
              setState(() {
                _isLoading = false;
              });
            });
          }
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
            // reset back the total streak to 0
            _totalStreak = 0;
            await LocalBox.put(key: 'total_streak', value: _totalStreak);

            // update the score
            _updateScore(false);

            // generate the answer list and put on the answer list
            AnswerList answerData0 = AnswerList(answer: _answer, correct: false);
            _answerList.add(answerData0);
            await _putAnswerList();

            // save the state as reset
            await _saveState(isReset: true);

            if (mounted) {
              showAlertDialog(
                context: context,
                title: "You Lose",
                body: "Try again next time, correct answer is $_answer",
                headword: _defHeadword,
                part: _defPart,
                meaning: _defMeaning,
                url: _defUrl,
                callback: _resetGame,
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
      }
    });
  }
  }
}