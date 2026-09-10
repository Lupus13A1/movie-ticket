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
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('MOVIE DETAIL'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: AppTheme.foreground, height: 2.0),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.foreground),
        ),
      );
    }

    if (_errorMessage != null || _movieDetails == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('ERROR')),
        body: Center(
          child: Text(
            _errorMessage ?? 'Failed to load details',
            style: const TextStyle(
              fontFamily: AppTheme.fontMono,
              color: AppTheme.foreground,
            ),
          ),
        ),
      );
    }

    final movie = _movieDetails!;
    final title = movie['title'] ?? 'UNKNOWN';
    final overview = movie['overview'] ?? 'No overview available.';
    final posterPath = movie['poster_path'];
    final backdropPath = movie['backdrop_path'];
    final voteAverage = (movie['vote_average'] ?? 0).toDouble();
    final runtime = movie['runtime'] ?? 0;
    final genres =
        (movie['genres'] as List?)?.map((g) => g['name']).toList() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('MOVIE DETAIL'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.foreground, height: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE SECTION
            if (backdropPath != null || posterPath != null)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(color: AppTheme.foreground, width: 4),
                  ),
                  color: AppTheme.muted,
                ),
                child: Image.network(
                  '${Constants.tmdbImageBaseUrl}${backdropPath ?? posterPath}',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GENRES
                  if (genres.isNotEmpty)
                    Text(
                      genres.join(' • ').toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // TITLE
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontDisplay,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      letterSpacing: -1.5,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // RATING AND RUNTIME
                  Row(
                    children: [
                      // Rating Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.foreground,
                          border: Border.all(
                            color: AppTheme.foreground,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppTheme.background,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontMono,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Runtime
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.foreground,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: AppTheme.foreground,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$runtime MIN',
                              style: const TextStyle(
                                fontFamily: AppTheme.fontMono,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // OVERVIEW TITLE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.foreground,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'THE STORY',
                      style: TextStyle(
                        fontFamily: AppTheme.fontBody,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OVERVIEW TEXT
                  Text(
                    overview,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontBody,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BOOK TICKETS',
                    style: TextStyle(
                      fontFamily: AppTheme.fontMono,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
