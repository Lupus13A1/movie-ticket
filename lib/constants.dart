import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbAccessToken => dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';

  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}
