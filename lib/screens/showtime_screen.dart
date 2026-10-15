import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/showtime.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import 'seat_selection_screen.dart';

class ShowtimeScreen extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String posterPath;

  const ShowtimeScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.posterPath,
  });

  @override
  State<ShowtimeScreen> createState() => _ShowtimeScreenState();
}

class _ShowtimeScreenState extends State<ShowtimeScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Showtime> _showtimes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final firebaseService = context.read<FirebaseService>();
    await firebaseService.generateMockShowtimes(
      widget.movieId,
      widget.movieTitle,
      widget.posterPath,
    );
    _fetchShowtimes();
  }

  Future<void> _fetchShowtimes() async {
    setState(() => _isLoading = true);
    final firebaseService = context.read<FirebaseService>();
    final showtimes = await firebaseService.getShowtimes(widget.movieId);

    if (mounted) {
      setState(() {
        _showtimes = showtimes;
        _isLoading = false;
      });
    }
  }

  List<DateTime> _generateDates() {
    final today = DateTime.now();
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  List<Showtime> _getShowtimesForSelectedDate() {
    final now = DateTime.now();
    final isSelectedToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    return _showtimes.where((st) {
      final isSameDay =
          st.time.year == _selectedDate.year &&
          st.time.month == _selectedDate.month &&
          st.time.day == _selectedDate.day;

      if (!isSameDay) return false;

      if (isSelectedToday) {
        if (st.time.isBefore(now)) return false;
      }
      return true;
    }).toList();
  }

  Map<String, List<Showtime>> _groupShowtimesByCinema(
    List<Showtime> showtimes,
  ) {
    final map = <String, List<Showtime>>{};
    for (var st in showtimes) {
      if (!map.containsKey(st.cinemaName)) {
        map[st.cinemaName] = [];
      }
      map[st.cinemaName]!.add(st);
    }
    for (var list in map.values) {
      list.sort((a, b) => a.time.compareTo(b.time));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDates();
    final dailyShowtimes = _getShowtimesForSelectedDate();
    final groupedShowtimes = _groupShowtimesByCinema(dailyShowtimes);
    final now = DateTime.now();
    final isSelectedToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(widget.movieTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // DATE SELECTOR
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 64,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.foreground
                                : AppTheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppTheme.foreground
                                : AppTheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // SHOWTIMES LIST
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : groupedShowtimes.isEmpty
                ? Center(
                    child: Text(
                      isSelectedToday
                          ? 'No showtimes remaining today'
                          : 'No showtimes available',
                      style: const TextStyle(color: AppTheme.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: groupedShowtimes.length,
                    itemBuilder: (context, index) {
                      final cinemaName = groupedShowtimes.keys.elementAt(index);
                      final times = groupedShowtimes[cinemaName]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CINEMA NAME
                            Text(
                              cinemaName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.foreground,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // TIME BUTTONS
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: times.map((st) {
                                final bool isPast = st.isPast;
                                final bool isClosingSoon = st.isClosingSoon;
                                final Color bgColor = isPast
                                    ? AppTheme.surface.withOpacity(0.5)
                                    : AppTheme.surface;
                                final Color textColor = isPast
                                    ? AppTheme.mutedForeground
                                    : AppTheme.foreground;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: isPast
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SeatSelectionScreen(
                                                    showtime: st,
                                                    movieTitle:
                                                        widget.movieTitle,
                                                    posterPath:
                                                        widget.posterPath,
                                                  ),
                                            ),
                                          );
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(4),
                                      border: isClosingSoon && !isPast
                                          ? Border.all(
                                              color: AppTheme.primary,
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          DateFormat('HH:mm').format(st.time),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${st.format}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isPast
                                                ? AppTheme.mutedForeground
                                                : AppTheme.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
