import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/movie.dart';

class TmdbService {
  Future<List<Movie>> getNowPlaying() async {
    final response = await http.get(
      Uri.parse(
        '${Constants.tmdbBaseUrl}/movie/now_playing?api_key=${Constants.tmdbApiKey}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }

  Future<List<Movie>> getPopular() async {
    final response = await http.get(
      Uri.parse(
        '${Constants.tmdbBaseUrl}/movie/popular?api_key=${Constants.tmdbApiKey}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse(
        '${Constants.tmdbBaseUrl}/search/movie?api_key=${Constants.tmdbApiKey}&query=$query',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }
}
