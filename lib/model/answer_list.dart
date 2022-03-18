// To parse this JSON data, do
//
//     final answerList = answerListFromJson(jsonString);

import 'dart:convert';

List<AnswerList> answerListFromJson(String str) => List<AnswerList>.from(json.decode(str).map((x) => AnswerList.fromJson(x)));

String answerListToJson(List<AnswerList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AnswerList {
    AnswerList({
        required this.answer,
        required this.correct,
    });

    final String answer;
    final bool correct;

    factory AnswerList.fromJson(Map<String, dynamic> json) => AnswerList(
        answer: json["answer"],
        correct: json["correct"],
    );

    Map<String, dynamic> toJson() => {
        "answer": answer,
        "correct": correct,
    };
}
