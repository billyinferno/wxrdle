import 'package:flutter/material.dart';
import 'package:wxrdle/globals/colors.dart';

class GameSelector extends StatefulWidget {
  final int selectedGameMode;
  final Map<int, String> gameType;
  final Function(int) onSelect;
  const GameSelector({ super.key, required this. selectedGameMode, required this.gameType, required this.onSelect });

  @override
  State<GameSelector> createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  late int _selectedGameMode;

  @override
  void initState() {
    super.initState();
    _selectedGameMode = widget.selectedGameMode;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List<Widget>.generate(widget.gameType.length, (index) {
        return InkWell(
          onTap: (() {
            widget.onSelect(index);
            setState(() {
              _selectedGameMode = index;
            });
          }),
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: (_selectedGameMode == index ? correctGuess : Colors.white),
                style: BorderStyle.solid,
                width: 1.0,
              )
            ),
            child: Center(
              child: Text(
                widget.gameType[index]!,
                style: TextStyle(
                  color: (_selectedGameMode == index ? correctGuess : Colors.white)
                ),
              )
            ),
          ),
        );
      }),
    );
  }
}