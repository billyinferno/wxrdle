import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wxrdle/globals/url.dart';
import 'package:wxrdle/model/definition_model.dart';
import 'package:wxrdle/model/word_list.dart';

class GetWordsAPI {
  // Future<WordList> getWords({String? startChar, String? endChar, required int length, String? dictionary}) async {
  Future<WordList> getWords({required String startChar, required String endChar, required int length}) async {
    // generate the url based on the startChar and endChar
    String currentApiURL = "${URLConfig.apiUrl}get-words/start/$startChar/end/$endChar/length/$length";

    final response = await http.get(
      Uri.parse(currentApiURL),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if(response.statusCode == 200) {
      // parse the response to get the word list
      // debugPrint(response.body);
      WordList wordList = WordList.fromJson(jsonDecode(response.body));
      return wordList;
    }
    else {
      throw Exception("Error when trying to get word from API");
    }
  }

  Future<bool> searchWords({required String word}) async {
    // generate the url based on the startChar and endChar
    String currentApiURL = "${URLConfig.apiUrl}search-words/word/${word.toLowerCase().trim()}/length/${word.trim().length}";

    final response = await http.get(
      Uri.parse(currentApiURL),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if(response.statusCode == 200) {
      // parse the response to get the word list
      WordList wordList = WordList.fromJson(jsonDecode(response.body));
      if(wordList.wordPages.isEmpty) {
        return true;
      }

      // wordPages is not empty, means we need to loop and see whether there are any word match
      // if there are word match then return as false, if not, then return as true
      WordPage wp = wordList.wordPages[0];
      for (WordListElement wl in wp.wordList) {
        if(wl.word.toLowerCase() == word.toLowerCase()) {
          return false;
        }
      }
      return true;
    }
    else {
      throw Exception("Error when trying to get word from API");
    }
  }

  Future<DefinitionModel> getDefinition({required String word}) async {
    String currentDefUrl = URLConfig.defUrl + word;

    final response = await http.get(
      Uri.parse(currentDefUrl),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if(response.statusCode == 200) {
      // parse the response to get the word list
      // debugPrint(response.body);
      DefinitionModel def = DefinitionModel.fromJson(jsonDecode(response.body));
      return def;
    }
    else {
      throw Exception("Error when trying to get word definition from API");
    }
  }
}