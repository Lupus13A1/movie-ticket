import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import '../constants.dart';
import '../l10n/app_translations.dart';
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.foreground,
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _navigateToDetail(movie.id),
      child: Container(
        width: 110, // Netflix-like poster width
        margin: const EdgeInsets.only(right: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: movie.posterPath.isNotEmpty
              ? Image.network(
                  '${Constants.tmdbImageBaseUrl}${movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.surface,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppTheme.surface,
                  child: const Center(
                    child: Icon(
                      Icons.movie_outlined,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMovieList(List<Movie>? movies, String Function(String) tr) {
    if (movies == null || movies.isEmpty) {
      return SizedBox(
        height: 165,
        child: Center(
          child: Text(
            tr('home.noMovies'),
            style: const TextStyle(color: AppTheme.mutedForeground),
          ),
        ),
      );
    }
    return SizedBox(
      height: 165, // Poster height
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return _buildMovieCard(movies[index]);
        },
      ),
    );
  }

  Widget _buildHeroSection(String Function(String) tr) {
    if (_popular == null || _popular!.isEmpty) return const SizedBox.shrink();

    final movie = _popular!.first; // Show the top popular movie
    final genreNames = movie.genreIds
        .take(3)
        .map((id) => _genres?[id] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () => _navigateToDetail(movie.id),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Large Poster Image
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  '${Constants.tmdbImageBaseUrl}${movie.posterPath}',
                ),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppTheme.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0],
              ),
            ),
          ),
          // Movie Info Overlay
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      genreNames.join(' • '),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _navigateToDetail(movie.id),
                      icon: const Icon(
                        Icons.play_arrow,
                        color: AppTheme.background,
                      ),
                      label: Text(
                        tr('home.bookNow'),
                        style: const TextStyle(color: AppTheme.background),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.foreground,
                        foregroundColor: AppTheme.background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _navigateToDetail(movie.id),
                      icon: const Icon(
                        Icons.info_outline,
                        color: AppTheme.foreground,
                      ),
                      label: Text(
                        tr('home.details'),
                        style: const TextStyle(color: AppTheme.foreground),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.transparent),
                        backgroundColor: AppTheme.surface.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(String Function(String) tr) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error:\n$_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.mutedForeground),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(tr),
            const SizedBox(height: 16),
            _buildSectionHeader(tr('home.nowPlaying')),
            _buildMovieList(_nowPlaying, tr),
            const SizedBox(height: 24),
            _buildSectionHeader(tr('home.popularOnCinema')),
            _buildMovieList(_popular, tr),
            const SizedBox(height: 24),
            _buildSectionHeader(tr('home.comingSoon')),
            _buildMovieList(_upcoming, tr),
            const SizedBox(height: 48), // Padding at bottom
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'CINEMA',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -1.0,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    size: 28,
                    color: AppTheme.foreground,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person,
                    size: 28,
                    color: AppTheme.foreground,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2; // Go to profile
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(tr),
          MyBookingsScreen(key: ValueKey(_bookingsRefreshKey)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 1) _bookingsRefreshKey++;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: tr('nav.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_activity_outlined),
            activeIcon: const Icon(Icons.local_activity),
            label: tr('nav.tickets'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu),
            activeIcon: const Icon(Icons.menu),
            label: tr('nav.more'),
          ),
        ],
      ),
    );
  }
}
