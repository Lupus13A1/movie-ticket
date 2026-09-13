import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/showtime.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import 'booking_success_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Showtime showtime;
  final String movieTitle;
  final String posterPath;
  final List<String> selectedSeats;
  final double totalPrice;

  const BookingSummaryScreen({
    super.key,
    required this.showtime,
    required this.movieTitle,
    required this.posterPath,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isProcessing = false;

  Future<void> _confirmBooking() async {
    setState(() => _isProcessing = true);

    try {
      final authService = context.read<AuthService>();
      final firebaseService = context.read<FirebaseService>();
      final user = authService.user;

      if (user == null) throw Exception('USER NOT LOGGED IN');

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
        // Success
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              movieTitle: widget.movieTitle,
              cinemaName: widget.showtime.cinemaName,
              time: widget.showtime.time,
              seats: widget.selectedSeats,
            ),
          ),
          (route) => route.isFirst, // Pop back to home as the root
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'BOOKING FAILED: ${e.toString()}',
              style: const TextStyle(fontFamily: AppTheme.fontMono),
            ),
            backgroundColor: Colors.transparent,
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
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: AppTheme.fontMono,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedForeground,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.toUpperCase(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppTheme.fontMono,
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('SUMMARY'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.foreground, height: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // RECEIPT CARD
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.foreground, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.movieTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontDisplay,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.foreground,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(height: 2, color: AppTheme.foreground),
                  const SizedBox(height: 24),

                  _buildSummaryRow('Cinema', widget.showtime.cinemaName),
                  _buildSummaryRow('Format', widget.showtime.format),
                  _buildSummaryRow(
                    'Date',
                    DateFormat('dd MMM yyyy').format(widget.showtime.time),
                  ),
                  _buildSummaryRow(
                    'Time',
                    DateFormat('HH:mm').format(widget.showtime.time),
                  ),
                  _buildSummaryRow('Seats', widget.selectedSeats.join(', ')),

                  const SizedBox(height: 24),
                  Container(height: 2, color: AppTheme.foreground),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontFamily: AppTheme.fontDisplay,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.foreground,
                        ),
                      ),
                      Text(
                        '฿${widget.totalPrice.toInt()}',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontDisplay,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.foreground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // CONFIRM BUTTON
            SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _confirmBooking,
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: AppTheme.background,
                      )
                    : const Text(
                        'CONFIRM BOOKING',
                        style: TextStyle(
                          fontFamily: AppTheme.fontMono,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
