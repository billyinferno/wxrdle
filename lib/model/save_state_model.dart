// To parse this JSON data, do
//
//     final saveStateModel = saveStateModelFromJson(jsonString);

import 'dart:convert';

SaveStateModel saveStateModelFromJson(String str) => SaveStateModel.fromJson(json.decode(str));

String saveStateModelToJson(SaveStateModel data) => json.encode(data.toJson());

class SaveStateModel {
    SaveStateModel({
        required this.currentIndex,
        required this.answer,
        required this.answerPoints,
        required this.answerList,
        this.defHeadword,
        this.defPart,
        this.defMeaning,
        this.defUrl,
        required this.keyboardMap,
    });

    final int currentIndex;
    final String answer;
    final int answerPoints;
    final List<SaveAnswerList> answerList;
    final String? defHeadword;
    final String? defPart;
    final String? defMeaning;
    final String? defUrl;
    final List<KeyboardMap> keyboardMap;

    factory SaveStateModel.fromJson(Map<String, dynamic> json) => SaveStateModel(
        currentIndex: json["current_index"],
        answer: json["answer"],
        answerPoints: json["answerPoints"],
        defHeadword: json["defHeadword"],
        defPart: json["defPart"],
        defMeaning: json["defMeaning"],
        defUrl: json["defUrl"],
        answerList: List<SaveAnswerList>.from(json["answer_list"].map((x) => SaveAnswerList.fromJson(x))),
        keyboardMap: List<KeyboardMap>.from(json["keyboard_map"].map((x) => KeyboardMap.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "current_index": currentIndex,
        "answer": answer,
        "answerPoints": answerPoints,
        "answer_list": List<dynamic>.from(answerList.map((x) => x.toJson())),
        "defHeadword": defHeadword,
        "defPart": defPart,
        "defMeaning": defMeaning,
        "defUrl": defUrl,
        "keyboard_map": List<dynamic>.from(keyboardMap.map((x) => x.toJson())),
    };
}

class SaveAnswerList {
    SaveAnswerList({
        required this.answer,
        required this.result,
    });

    final String answer;
    final bool result;

    factory SaveAnswerList.fromJson(Map<String, dynamic> json) => SaveAnswerList(
        answer: json["answer"],
        result: json["result"],
    );

    Map<String, dynamic> toJson() => {
        "answer": answer,
        "result": result,
    };
}

class KeyboardMap {
    KeyboardMap({
        required this.id,
        required this.map,
    });

    final int id;
    final List<int> map;

    factory KeyboardMap.fromJson(Map<String, dynamic> json) => KeyboardMap(
        id: json["id"],
        map: List<int>.from(json["map"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "map": List<dynamic>.from(map.map((x) => x)),
    };
}
