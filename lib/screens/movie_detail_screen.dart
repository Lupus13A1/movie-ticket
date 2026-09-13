import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import '../constants.dart';
import 'showtime_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final tmdb = context.read<TmdbService>();
      final details = await tmdb.getMovieDetails(widget.movieId);
      if (mounted) {
        setState(() {
          _movieDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_errorMessage != null || _movieDetails == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            _errorMessage ?? 'Failed to load details',
            style: const TextStyle(color: AppTheme.foreground),
          ),
        ),
      );
    }

    final movie = _movieDetails!;
    final title = movie['title'] ?? 'Unknown';
    final overview = movie['overview'] ?? 'No overview available.';
    final posterPath = movie['poster_path'];
    final backdropPath = movie['backdrop_path'];
    final voteAverage = (movie['vote_average'] ?? 0).toDouble();
    final runtime = movie['runtime'] ?? 0;
    final genres =
        (movie['genres'] as List?)?.map((g) => g['name']).toList() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.foreground),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HERO BACKDROP WITH GRADIENT
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (backdropPath != null || posterPath != null)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          '${Constants.tmdbImageBaseUrl}${backdropPath ?? posterPath}',
                        ),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  )
                else
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    color: AppTheme.surface,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ),
                // Gradient fade to background
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppTheme.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata (Rating, Runtime, Year)
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${movie['release_date']?.toString().split('-').first ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$runtime m',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BOOK TICKETS BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowtimeScreen(
                              movieId: widget.movieId,
                              movieTitle: title,
                              posterPath: posterPath ?? '',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_activity),
                      label: const Text('Book Tickets'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Genres
                  if (genres.isNotEmpty)
                    Text(
                      genres.join(' • '),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.foreground,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Overview Text
                  Text(
                    overview,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
