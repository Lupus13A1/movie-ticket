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
    _releaseAllHeldSeats();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
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
      } catch (_) {}
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
          content: Text('Seat hold expired. Please select again.'),
          backgroundColor: AppTheme.error,
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

    if (_userId != null) {
      if (_selectedSeats.contains(seatId)) {
        await firebaseService.holdSeats(
          showtimeId: widget.showtime.id,
          seats: [seatId],
          userId: _userId!,
        );
      } else {
        await firebaseService.releaseSeats(
          showtimeId: widget.showtime.id,
          seats: [seatId],
          userId: _userId!,
        );
      }
    }

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
    double seatSize,
  ) {
    final isBooked = bookedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);
    final isHeldByOther = heldByOthers.containsKey(seatId);

    Color bgColor = AppTheme.surface;
    Color borderColor = Colors.transparent;
    Color textColor = AppTheme.mutedForeground;

    if (isBooked) {
      bgColor = AppTheme.background;
      borderColor = AppTheme.surface;
      textColor = AppTheme.surface; // almost invisible
    } else if (isHeldByOther) {
      bgColor = AppTheme.surface;
      borderColor = AppTheme.primaryYellow;
      textColor = AppTheme.primaryYellow;
    } else if (isSelected) {
      bgColor = AppTheme.primary;
      textColor = AppTheme.foreground;
    } else {
      // Available
      bgColor = AppTheme.surface;
      textColor = AppTheme.foreground;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seatId, bookedSeats, heldByOthers),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: seatSize,
        height: seatSize,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: borderColor,
            width: isSelected || isHeldByOther ? 1.5 : 0,
          ),
        ),
        alignment: Alignment.center,
        child: isBooked
            ? const Icon(Icons.close, size: 16, color: AppTheme.surface)
            : Text(
                seatId,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color bgColor, {
    Color? iconColor,
    IconData? icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: icon != null ? Icon(icon, size: 12, color: iconColor) : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate seat size based on screen width (8 cols + 1 aisle + padding)
    final double maxSeatSize = (screenWidth - 48 - (8 * 8) - 24) / 8;
    final double seatSize = maxSeatSize > 40 ? 40 : maxSeatSize;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _bookedSeatsRef.onValue,
        builder: (context, bookedSnapshot) {
          if (bookedSnapshot.hasError) {
            return const Center(child: Text('Error loading seats'));
          }
          if (bookedSnapshot.connectionState == ConnectionState.waiting &&
              !bookedSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          List<String> bookedSeats = [];
          if (bookedSnapshot.hasData &&
              bookedSnapshot.data!.snapshot.value != null) {
            final dataList =
                bookedSnapshot.data!.snapshot.value as List<dynamic>;
            bookedSeats = dataList.map((e) => e.toString()).toList();
          }

          _selectedSeats.removeWhere((seat) => bookedSeats.contains(seat));

          return StreamBuilder<DatabaseEvent>(
            stream: _seatHoldsRef.onValue,
            builder: (context, holdsSnapshot) {
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

              _selectedSeats.removeWhere(
                (seat) => heldByOthers.containsKey(seat),
              );

              return Column(
                children: [
                  const SizedBox(height: 16),
                  // SCREEN INDICATOR (Netflix curved line)
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          border: const Border(
                            top: BorderSide(color: AppTheme.primary, width: 3),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.elliptical(200, 20),
                            topRight: Radius.elliptical(200, 20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primary.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'SCREEN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // SEATING GRID
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 2.0,
                      boundaryMargin: const EdgeInsets.all(24),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _rows.map((row) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_cols, (colIndex) {
                                  final seatId = '$row${colIndex + 1}';
                                  if (colIndex == 4) {
                                    return Row(
                                      children: [
                                        const SizedBox(width: 24), // Aisle
                                        _buildSeat(
                                          seatId,
                                          bookedSeats,
                                          heldByOthers,
                                          seatSize,
                                        ),
                                      ],
                                    );
                                  }
                                  return _buildSeat(
                                    seatId,
                                    bookedSeats,
                                    heldByOthers,
                                    seatSize,
                                  );
                                }),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // LEGEND
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildLegendItem('Available', AppTheme.surface),
                        _buildLegendItem('Selected', AppTheme.primary),
                        _buildLegendItem(
                          'Booked',
                          AppTheme.background,
                          iconColor: AppTheme.surface,
                          icon: Icons.close,
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
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedSeats.isNotEmpty && _remainingSeconds > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: _remainingSeconds <= 60
                                ? AppTheme.error
                                : AppTheme.foreground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimer(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _remainingSeconds <= 60
                                  ? AppTheme.error
                                  : AppTheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    Text(
                      '${_selectedSeats.length} Seat(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    Text(
                      '฿${(_selectedSeats.length * widget.showtime.price).toInt()}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
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
                              selectedSeats: List<String>.from(_selectedSeats),
                              totalPrice:
                                  _selectedSeats.length * widget.showtime.price,
                              holdExpiresAt: _holdExpiresAt,
                            ),
                          ),
                        );
                      },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
