import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/joke_model.dart';

class ApiService {
  static Future<Joke> fetchJoke() async {
    final url = Uri.parse('https://official-joke-api.appspot.com/random_joke');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Joke.fromJson(data);
    } else {
      throw Exception('Failed to load joke');
    }
  }
}
