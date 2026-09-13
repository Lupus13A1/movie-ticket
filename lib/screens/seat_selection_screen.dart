import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/showtime.dart';
import '../theme/app_theme.dart';
import 'booking_summary_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Showtime showtime;
  final String movieTitle;
  final String posterPath;

  const SeatSelectionScreen({
    super.key,
    required this.showtime,
    required this.movieTitle,
    required this.posterPath,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  final List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  final int _cols = 8;
  late final DatabaseReference _bookedSeatsRef;

  @override
  void initState() {
    super.initState();
    _bookedSeatsRef = FirebaseDatabase.instance.ref(
      'showtimes/${widget.showtime.id}/bookedSeats',
    );
  }

  void _toggleSeat(String seatId, List<String> bookedSeats) {
    if (bookedSeats.contains(seatId)) return; // Already booked

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });
  }

  Widget _buildSeat(String seatId, List<String> bookedSeats) {
    final isBooked = bookedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);

    Color bgColor = AppTheme.background;
    Color borderColor = AppTheme.foreground;
    Color textColor = AppTheme.foreground;

    if (isBooked) {
      bgColor = AppTheme.muted;
      borderColor = AppTheme.mutedForeground;
      textColor = AppTheme.mutedForeground;
    } else if (isSelected) {
      bgColor = AppTheme.foreground;
      textColor = AppTheme.background;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seatId, bookedSeats),
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          seatId,
          style: TextStyle(
            fontFamily: AppTheme.fontMono,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color bgColor, Color borderColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppTheme.fontMono,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('SELECT SEATS'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.foreground, height: 2.0),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _bookedSeatsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'ERROR LOADING SEATS',
                style: TextStyle(fontFamily: AppTheme.fontMono),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.foreground),
            );
          }

          // Parse booked seats from Firebase
          List<String> bookedSeats = [];
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final dataList = snapshot.data!.snapshot.value as List<dynamic>;
            bookedSeats = dataList.map((e) => e.toString()).toList();
          }

          // If a selected seat was just booked by someone else, remove it
          _selectedSeats.removeWhere((seat) => bookedSeats.contains(seat));

          return Column(
            children: [
              const SizedBox(height: 32),

              // SCREEN INDICATOR
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 48),
                height: 4,
                width: double.infinity,
                color: AppTheme.foreground,
              ),
              const SizedBox(height: 8),
              const Text(
                'SCREEN',
                style: TextStyle(
                  fontFamily: AppTheme.fontMono,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4.0,
                  color: AppTheme.foreground,
                ),
              ),
              const SizedBox(height: 48),

              // SEATING GRID
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: _rows.map((row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_cols, (colIndex) {
                          final seatId = '$row${colIndex + 1}';
                          // Add an aisle space after col 4
                          if (colIndex == 4) {
                            return Row(
                              children: [
                                const SizedBox(width: 24), // Aisle
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: _buildSeat(seatId, bookedSeats),
                                ),
                              ],
                            );
                          }
                          return SizedBox(
                            width: 40,
                            height: 40,
                            child: _buildSeat(seatId, bookedSeats),
                          );
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // LEGEND
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                      'Available',
                      AppTheme.background,
                      AppTheme.foreground,
                    ),
                    _buildLegendItem(
                      'Selected',
                      AppTheme.foreground,
                      AppTheme.foreground,
                    ),
                    _buildLegendItem(
                      'Booked',
                      AppTheme.muted,
                      AppTheme.mutedForeground,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppTheme.foreground, width: 2),
            ),
            color: AppTheme.background,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedSeats.length} SEAT(S)',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    Text(
                      '฿${(_selectedSeats.length * widget.showtime.price).toInt()}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontDisplay,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _selectedSeats.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingSummaryScreen(
                              showtime: widget.showtime,
                              movieTitle: widget.movieTitle,
                              posterPath: widget.posterPath,
                              selectedSeats: _selectedSeats,
                              totalPrice:
                                  _selectedSeats.length * widget.showtime.price,
                            ),
                          ),
                        );
                      },
                child: const Row(
                  children: [
                    Text('CONTINUE'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
