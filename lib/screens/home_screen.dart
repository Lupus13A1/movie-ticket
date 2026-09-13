import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import '../constants.dart';
import 'movie_detail_screen.dart';
import 'profile_screen.dart';
import 'my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex = widget.initialTabIndex;
  int _bookingsRefreshKey = 0;
  List<Movie>? _nowPlaying;
  List<Movie>? _popular;
  List<Movie>? _upcoming;
  Map<int, String>? _genres;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final tmdb = context.read<TmdbService>();
      final results = await Future.wait([
        tmdb.getNowPlaying(),
        tmdb.getPopular(),
        tmdb.getUpcoming(),
        tmdb.getGenres(),
      ]);

      if (mounted) {
        setState(() {
          _nowPlaying = results[0] as List<Movie>;
          _popular = results[1] as List<Movie>;
          _upcoming = results[2] as List<Movie>;
          _genres = results[3] as Map<int, String>;
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

  void _navigateToDetail(int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movieId: movieId),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    Color accentColor = AppTheme.primaryRed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accentColor,
              border: AppTheme.border2,
              boxShadow: const [AppTheme.hardShadow],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: AppTheme.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
    // Get up to 2 genres
    final genreNames = movie.genreIds
        .take(2)
        .map((id) => _genres?[id] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final primaryColor =
        AppTheme.primaryColors[index % AppTheme.primaryColors.length];

    return GestureDetector(
      onTap: () => _navigateToDetail(movie.id),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(left: 24.0, bottom: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Container(
              height: 225,
              width: 150,
              decoration: AppTheme.cardDecoration(
                color: primaryColor,
                thickBorder: true,
              ),
              child: movie.posterPath.isNotEmpty
                  ? Image.network(
                      '${Constants.tmdbImageBaseUrl}${movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppTheme.foreground,
                            ),
                          ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.movie_outlined,
                        color: AppTheme.foreground,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              movie.title.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.foreground,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            // Genres & Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    color: AppTheme.foreground,
                    child: Text(
                      genreNames.join(', ').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppTheme.background,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 14, color: AppTheme.foreground),
                const SizedBox(width: 2),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieList(List<Movie>? movies) {
    if (movies == null || movies.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'NO DATA AVAILABLE',
            style: TextStyle(fontFamily: AppTheme.fontMono),
          ),
        ),
      );
    }
    return SizedBox(
      height: 330, // Increased to accommodate shadows
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == movies.length - 1 ? 24.0 : 0,
            ),
            child: _buildMovieCard(movie, index),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    if (_popular == null || _popular!.isEmpty) return const SizedBox.shrink();

    // Use top 5 popular movies for the hero section
    final heroMovies = _popular!.take(5).toList();

    return SizedBox(
      height: 620, // Increased height to fit oversized elements and shadows
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: heroMovies.length,
        itemBuilder: (context, index) {
          final movie = heroMovies[index];
          final genreNames = movie.genreIds
              .map((id) => _genres?[id] ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

          final accentColor =
              AppTheme.primaryColors[index % AppTheme.primaryColors.length];

          return GestureDetector(
            onTap: () => _navigateToDetail(movie.id),
            child: Container(
              color: AppTheme.background,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Highlight Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: AppTheme.foreground,
                    child: Semantics(
                      header: true,
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontFamily: AppTheme.fontMono,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.background,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Big Poster with Bauhaus Card Decoration
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        bottom: 8.0,
                        right: 8.0,
                      ), // space for shadow
                      decoration: AppTheme.cardDecoration(
                        color: accentColor,
                        thickBorder: true,
                        largeShadow: true,
                      ),
                      child: movie.posterPath.isNotEmpty
                          ? Image.network(
                              '${Constants.tmdbImageBaseUrl}${movie.posterPath}',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : const Center(
                              child: Icon(
                                Icons.movie_outlined,
                                size: 48,
                                color: AppTheme.foreground,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    movie.title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: AppTheme.foreground,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Genres & Rating as geometric blocks
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          border: AppTheme.border2,
                        ),
                        child: Text(
                          genreNames.join(' • ').toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontMono,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: AppTheme.foreground,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppTheme.primaryYellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontMono,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Overview
                  Text(
                    movie.overview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.foreground,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.foreground),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'ERROR:\n$_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontMono,
              color: AppTheme.foreground,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.background,
      backgroundColor: AppTheme.foreground,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        children: [
          _buildHeroSection(),
          const Divider(thickness: 4, height: 4, color: AppTheme.foreground),

          _buildSectionHeader('กำลังฉาย'),
          _buildMovieList(_nowPlaying),

          const SizedBox(height: 32),
          const Divider(thickness: 4, height: 4, color: AppTheme.foreground),
          const SizedBox(height: 8),

          _buildSectionHeader('ยอดนิยม'),
          _buildMovieList(_popular),

          const SizedBox(height: 32),
          const Divider(thickness: 4, height: 4, color: AppTheme.foreground),
          const SizedBox(height: 8),

          _buildSectionHeader('กำลังจะเข้าฉาย'),
          _buildMovieList(_upcoming),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('CINEMA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            tooltip: 'Search movies',
            onPressed: () {
              // Navigate to search screen
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.foreground, height: 2.0),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          MyBookingsScreen(key: ValueKey(_bookingsRefreshKey)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.foreground, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 1) _bookingsRefreshKey++;
            });
          },
          backgroundColor: AppTheme.background,
          selectedItemColor: AppTheme.foreground,
          unselectedItemColor: AppTheme.mutedForeground,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: AppTheme.fontMono,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: AppTheme.fontMono,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home),
              ),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.local_activity_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.local_activity),
              ),
              label: 'TICKETS',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person),
              ),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
