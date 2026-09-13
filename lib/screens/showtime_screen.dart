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
    // Seed data if none exists
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
    return _showtimes.where((st) {
      return st.time.year == _selectedDate.year &&
          st.time.month == _selectedDate.month &&
          st.time.day == _selectedDate.day;
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
    // Sort times
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.movieTitle.toUpperCase()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.foreground, height: 2.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // DATE SELECTOR
          Container(
            height: 90,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.foreground, width: 2),
              ),
            ),
            child: ListView.builder(
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
                    width: 80,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.foreground
                          : AppTheme.background,
                      border: Border.all(color: AppTheme.foreground, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(
                            'E',
                          ).format(date).toUpperCase(), // e.g., MON
                          style: TextStyle(
                            fontFamily: AppTheme.fontMono,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.background
                                : AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}', // e.g., 15
                          style: TextStyle(
                            fontFamily: AppTheme.fontDisplay,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? AppTheme.background
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

          // SHOWTIMES LIST
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.foreground,
                    ),
                  )
                : groupedShowtimes.isEmpty
                ? const Center(
                    child: Text(
                      'NO SHOWTIMES AVAILABLE',
                      style: TextStyle(
                        fontFamily: AppTheme.fontMono,
                        color: AppTheme.foreground,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: groupedShowtimes.length,
                    itemBuilder: (context, index) {
                      final cinemaName = groupedShowtimes.keys.elementAt(index);
                      final times = groupedShowtimes[cinemaName]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CINEMA NAME
                            Text(
                              cinemaName.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontDisplay,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: AppTheme.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 2,
                              width: double.infinity,
                              color: AppTheme.foreground,
                            ),
                            const SizedBox(height: 16),

                            // TIME BUTTONS
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: times.map((st) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SeatSelectionScreen(
                                              showtime: st,
                                              movieTitle: widget.movieTitle,
                                              posterPath: widget.posterPath,
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
                                      border: Border.all(
                                        color: AppTheme.foreground,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          DateFormat('HH:mm').format(st.time),
                                          style: const TextStyle(
                                            fontFamily: AppTheme.fontMono,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.foreground,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${st.format} | ฿${st.price.toInt()}',
                                          style: const TextStyle(
                                            fontFamily: AppTheme.fontMono,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.mutedForeground,
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
