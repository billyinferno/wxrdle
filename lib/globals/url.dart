// const String apiUrl = "https://fly.wordfinderapi.com/api/search?"; // starts_with=a&ends_with=a&length=5&word_sorting=points&group_by_length=false&page_size=99999&dictionary=all_en
import 'package:flutter_dotenv/flutter_dotenv.dart';

class URLConfig {
  static String apiUrl = (dotenv.env['URL'] ?? 'http://10.89.96.176:3498/get-words'); //start/x/end/z
  static String version = (dotenv.env['VERSION'] ?? '1.0.0');
  static String defUrl = "https://api.yourdictionary.com/wordfinder/v1/definitions/";
}
