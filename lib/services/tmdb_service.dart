import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/movie.dart';

class TmdbService {
  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${Constants.tmdbAccessToken}',
    'accept': 'application/json',
  };

  Future<List<Movie>> getNowPlaying() async {
    final response = await http.get(
      Uri.parse(
        '${Constants.tmdbBaseUrl}/movie/now_playing?language=en-US&page=1',
      ),
      headers: _headers,
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
      Uri.parse('${Constants.tmdbBaseUrl}/movie/popular?language=en-US&page=1'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getUpcoming() async {
    final response = await http.get(
      Uri.parse(
        '${Constants.tmdbBaseUrl}/movie/upcoming?language=en-US&page=1',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse(
        '${Constants.tmdbBaseUrl}/search/movie?language=en-US&query=$query&page=1',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<Map<int, String>> getGenres() async {
    final response = await http.get(
      Uri.parse('${Constants.tmdbBaseUrl}/genre/movie/list?language=en-US'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List genresData = data['genres'];
      Map<int, String> genres = {};
      for (var genre in genresData) {
        genres[genre['id']] = genre['name'];
      }
      return genres;
    } else {
      throw Exception('Failed to load genres');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('${Constants.tmdbBaseUrl}/movie/$movieId?language=en-US'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
