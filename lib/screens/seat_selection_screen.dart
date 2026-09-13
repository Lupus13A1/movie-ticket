import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../models/showtime.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
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

class _SeatSelectionScreenState extends State<SeatSelectionScreen>
    with WidgetsBindingObserver {
  final List<String> _selectedSeats = [];
  final List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  final int _cols = 8;
  late final DatabaseReference _bookedSeatsRef;
  late final DatabaseReference _seatHoldsRef;

  // Seat hold timer
  Timer? _holdTimer;
  DateTime? _holdExpiresAt;
  int _remainingSeconds = 0;
  static const int _holdDurationSeconds = 7 * 60; // 7 minutes

  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bookedSeatsRef = FirebaseDatabase.instance.ref(
      'showtimes/${widget.showtime.id}/bookedSeats',
    );
    _seatHoldsRef = FirebaseDatabase.instance.ref(
      'seatHolds/${widget.showtime.id}',
    );
    _userId = context.read<AuthService>().user?.uid;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _holdTimer?.cancel();
    // Release held seats when leaving the screen
    _releaseAllHeldSeats();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Release seats when app goes to background or is closed
      _releaseAllHeldSeats();
    }
  }

  Future<void> _releaseAllHeldSeats() async {
    if (_selectedSeats.isNotEmpty && _userId != null) {
      final firebaseService = context.read<FirebaseService>();
      try {
        await firebaseService.releaseSeats(
          showtimeId: widget.showtime.id,
          seats: List.from(_selectedSeats),
          userId: _userId!,
        );
      } catch (_) {
        // Best effort cleanup — don't crash if release fails
      }
    }
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdExpiresAt = DateTime.now().add(
      const Duration(seconds: _holdDurationSeconds),
    );
    _remainingSeconds = _holdDurationSeconds;

    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = _holdExpiresAt!.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        _onHoldExpired();
      } else {
        setState(() {
          _remainingSeconds = remaining;
        });
      }
    });
  }

  void _onHoldExpired() {
    _releaseAllHeldSeats();
    if (mounted) {
      setState(() {
        _selectedSeats.clear();
        _remainingSeconds = 0;
        _holdExpiresAt = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'SEAT HOLD EXPIRED — PLEASE SELECT AGAIN',
            style: TextStyle(fontFamily: AppTheme.fontMono),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimer(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleSeat(
    String seatId,
    List<String> bookedSeats,
    Map<String, String> heldByOthers,
  ) async {
    if (bookedSeats.contains(seatId)) return;
    if (heldByOthers.containsKey(seatId)) return;

    final firebaseService = context.read<FirebaseService>();

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });

    // Update holds in Firebase
    if (_userId != null) {
      if (_selectedSeats.contains(seatId)) {
        // Hold the newly selected seat
        await firebaseService.holdSeats(
          showtimeId: widget.showtime.id,
          seats: [seatId],
          userId: _userId!,
        );
      } else {
        // Release the deselected seat
        await firebaseService.releaseSeats(
          showtimeId: widget.showtime.id,
          seats: [seatId],
          userId: _userId!,
        );
      }
    }

    // Start or reset the hold timer when seats are selected
    if (_selectedSeats.isNotEmpty) {
      _startHoldTimer();
    } else {
      _holdTimer?.cancel();
      setState(() {
        _remainingSeconds = 0;
        _holdExpiresAt = null;
      });
    }
  }

  Widget _buildSeat(
    String seatId,
    List<String> bookedSeats,
    Map<String, String> heldByOthers,
  ) {
    final isBooked = bookedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);
    final isHeldByOther = heldByOthers.containsKey(seatId);

    Color bgColor = AppTheme.background;
    Color borderColor = AppTheme.foreground;
    Color textColor = AppTheme.foreground;

    if (isBooked) {
      bgColor = AppTheme.muted;
      borderColor = AppTheme.mutedForeground;
      textColor = AppTheme.mutedForeground;
    } else if (isHeldByOther) {
      bgColor = Colors.orange.withValues(alpha: 0.3);
      borderColor = Colors.orange;
      textColor = Colors.orange;
    } else if (isSelected) {
      bgColor = AppTheme.foreground;
      textColor = AppTheme.background;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seatId, bookedSeats, heldByOthers),
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
        builder: (context, bookedSnapshot) {
          if (bookedSnapshot.hasError) {
            return const Center(
              child: Text(
                'ERROR LOADING SEATS',
                style: TextStyle(fontFamily: AppTheme.fontMono),
              ),
            );
          }
          if (bookedSnapshot.connectionState == ConnectionState.waiting &&
              !bookedSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.foreground),
            );
          }

          // Parse booked seats from Firebase
          List<String> bookedSeats = [];
          if (bookedSnapshot.hasData &&
              bookedSnapshot.data!.snapshot.value != null) {
            final dataList =
                bookedSnapshot.data!.snapshot.value as List<dynamic>;
            bookedSeats = dataList.map((e) => e.toString()).toList();
          }

          // If a selected seat was just booked by someone else, remove it
          _selectedSeats.removeWhere((seat) => bookedSeats.contains(seat));

          return StreamBuilder<DatabaseEvent>(
            stream: _seatHoldsRef.onValue,
            builder: (context, holdsSnapshot) {
              // Parse held seats by other users
              Map<String, String> heldByOthers = {};
              if (holdsSnapshot.hasData &&
                  holdsSnapshot.data!.snapshot.value != null) {
                final holdsData = holdsSnapshot.data!.snapshot.value;
                if (holdsData is Map) {
                  final now = DateTime.now().millisecondsSinceEpoch;
                  for (final entry in holdsData.entries) {
                    final holdInfo = entry.value as Map<dynamic, dynamic>;
                    final holdUserId = holdInfo['userId'] as String? ?? '';
                    final expiresAt = holdInfo['expiresAt'] as int? ?? 0;

                    if (holdUserId != _userId && expiresAt > now) {
                      heldByOthers[entry.key.toString()] = holdUserId;
                    }
                  }
                }
              }

              // Remove selected seats that are now held by others
              _selectedSeats.removeWhere(
                (seat) => heldByOthers.containsKey(seat),
              );

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
                                      child: _buildSeat(
                                        seatId,
                                        bookedSeats,
                                        heldByOthers,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return SizedBox(
                                width: 40,
                                height: 40,
                                child: _buildSeat(
                                  seatId,
                                  bookedSeats,
                                  heldByOthers,
                                ),
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
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
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
                          'Held',
                          Colors.orange.withValues(alpha: 0.3),
                          Colors.orange,
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
                    // Timer display
                    if (_selectedSeats.isNotEmpty && _remainingSeconds > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 14,
                              color: _remainingSeconds <= 60
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimer(_remainingSeconds),
                              style: TextStyle(
                                fontFamily: AppTheme.fontMono,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: _remainingSeconds <= 60
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              selectedSeats: List.from(_selectedSeats),
                              totalPrice:
                                  _selectedSeats.length * widget.showtime.price,
                              holdExpiresAt: _holdExpiresAt,
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
