import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wxrdle/globals/url.dart';
import 'package:wxrdle/model/word_list.dart';

class GetWordsAPI {
  Future<WordList> getWords({String? startChar, String? endChar, required int length}) async {
    // generate the url based on the startChar and endChar
    String _apiUrl = apiUrl;
    bool _gotParam = false;

    if(startChar != null) {
      _apiUrl = _apiUrl + "starts_with=" + startChar;
      _gotParam = true;
    }

    if(endChar != null) {
      if(_gotParam) {
        _apiUrl = _apiUrl + "&";
      }
      _apiUrl = _apiUrl + "ends_with=" + endChar;
      _gotParam = true;
    }

    if(_gotParam) {
      _apiUrl = _apiUrl + "&";
    }
    _apiUrl = _apiUrl + "length=" + length.toString() + "&word_sorting=points&group_by_length=false&page_size=99999&dictionary=all_en";
    // debugPrint(_apiUrl);

    final response = await http.get(
      Uri.parse(_apiUrl),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if(response.statusCode == 200) {
      // parse the response to get the word list
      // debugPrint(response.body);
      WordList _wordList = WordList.fromJson(jsonDecode(response.body));
      return _wordList;
    }
    else {
      throw Exception("Error when trying to get word from API");
    }
  }
}