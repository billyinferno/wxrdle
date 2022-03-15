// To parse this JSON data, do
//
//     final wordList = wordListFromJson(jsonString);

import 'dart:convert';

WordList wordListFromJson(String str) => WordList.fromJson(json.decode(str));

String wordListToJson(WordList data) => json.encode(data.toJson());

class WordList {
    WordList({
        required this.wordPages,
    });

    final List<WordPage> wordPages;

    factory WordList.fromJson(Map<String, dynamic> json) => WordList(
        wordPages: (json["word_pages"] == null ? [] : List<WordPage>.from(json["word_pages"].map((x) => WordPage.fromJson(x)))),
    );

    Map<String, dynamic> toJson() => {
        "word_pages": List<dynamic>.from(wordPages.map((x) => x.toJson())),
    };
}

class WordPage {
    WordPage({
        required this.wordList,
        required this.numWords,
        required this.numPages,
        required this.currentPage,
    });

    final List<WordListElement> wordList;
    final int numWords;
    final int numPages;
    final int currentPage;

    factory WordPage.fromJson(Map<String, dynamic> json) => WordPage(
        wordList: List<WordListElement>.from(json["word_list"].map((x) => WordListElement.fromJson(x))),
        numWords: json["num_words"],
        numPages: json["num_pages"],
        currentPage: json["current_page"],
    );

    Map<String, dynamic> toJson() => {
        "word_list": List<dynamic>.from(wordList.map((x) => x.toJson())),
        "num_words": numWords,
        "num_pages": numPages,
        "current_page": currentPage,
    };
}

class WordListElement {
    WordListElement({
        required this.word,
        required this.points,
        required this.wildcards,
    });

    final String word;
    final int points;
    final List<dynamic> wildcards;

    factory WordListElement.fromJson(Map<String, dynamic> json) => WordListElement(
        word: json["word"],
        points: json["points"],
        wildcards: List<dynamic>.from(json["wildcards"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "word": word,
        "points": points,
        "wildcards": List<dynamic>.from(wildcards.map((x) => x)),
    };
}
