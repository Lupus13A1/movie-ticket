import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/showtime.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../constants.dart';
import 'booking_success_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Showtime showtime;
  final String movieTitle;
  final String posterPath;
  final List<String> selectedSeats;
  final double totalPrice;
  final DateTime? holdExpiresAt;

  const BookingSummaryScreen({
    super.key,
    required this.showtime,
    required this.movieTitle,
    required this.posterPath,
    required this.selectedSeats,
    required this.totalPrice,
    this.holdExpiresAt,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isProcessing = false;
  Timer? _holdTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startHoldCountdown();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHoldCountdown() {
    if (widget.holdExpiresAt == null) return;

    _remainingSeconds = widget.holdExpiresAt!
        .difference(DateTime.now())
        .inSeconds;
    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      return;
    }

    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = widget.holdExpiresAt!
          .difference(DateTime.now())
          .inSeconds;

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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seat hold expired. Please select seats again.'),
          backgroundColor: AppTheme.error,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _formatTimer(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmBooking() async {
    if (widget.holdExpiresAt != null &&
        DateTime.now().isAfter(widget.holdExpiresAt!)) {
      _onHoldExpired();
      return;
    }

    if (widget.showtime.isPast) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This showtime has already passed'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authService = context.read<AuthService>();
      final firebaseService = context.read<FirebaseService>();
      final user = authService.user;

      if (user == null) throw Exception('User not logged in');

      await firebaseService.bookSeats(
        showtimeId: widget.showtime.id,
        userId: user.uid,
        movieTitle: widget.movieTitle,
        selectedSeats: widget.selectedSeats,
        totalPrice: widget.totalPrice,
        posterPath: widget.posterPath,
        cinemaName: widget.showtime.cinemaName,
        format: widget.showtime.format,
        time: widget.showtime.time,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              movieTitle: widget.movieTitle,
              cinemaName: widget.showtime.cinemaName,
              time: widget.showtime.time,
              seats: widget.selectedSeats,
              format: widget.showtime.format,
              totalPrice: widget.totalPrice,
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HOLD TIMER
            if (_remainingSeconds > 0)
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 24.0),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _remainingSeconds <= 60
                        ? AppTheme.error
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: _remainingSeconds <= 60
                          ? AppTheme.error
                          : AppTheme.foreground,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete booking within',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                          Text(
                            _formatTimer(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _remainingSeconds <= 60
                                  ? AppTheme.error
                                  : AppTheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // RECEIPT CARD
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Poster & Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.posterPath.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                          ),
                          child: Image.network(
                            '${Constants.tmdbImageBaseUrl}${widget.posterPath}',
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            widget.movieTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.foreground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSummaryRow('Cinema', widget.showtime.cinemaName),
                        _buildSummaryRow('Format', widget.showtime.format),
                        _buildSummaryRow(
                          'Date',
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(widget.showtime.time),
                        ),
                        _buildSummaryRow(
                          'Time',
                          DateFormat('HH:mm').format(widget.showtime.time),
                        ),
                        _buildSummaryRow(
                          'Seats',
                          widget.selectedSeats.join(', '),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: AppTheme.borderColor),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.foreground,
                              ),
                            ),
                            Text(
                              '฿${widget.totalPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.foreground,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Confirm Booking'),
          ),
        ),
      ),
    );
  }
}
