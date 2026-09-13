import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String movieTitle;
  final String cinemaName;
  final DateTime time;
  final List<String> seats;
  final String format;
  final double totalPrice;

  const BookingSuccessScreen({
    super.key,
    required this.movieTitle,
    required this.cinemaName,
    required this.time,
    required this.seats,
    required this.format,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SUCCESS ICON
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 60,
                    color: AppTheme.foreground,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // SUCCESS TEXT
              const Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your tickets are ready.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.mutedForeground),
              ),
              const SizedBox(height: 32),

              // TICKET DETAILS
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      movieTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(time)} • ${DateFormat('HH:mm').format(time)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cinemaName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: AppTheme.borderColor),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seats',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        Text(
                          seats.join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Paid',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                        Text(
                          '฿${totalPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // BUTTONS
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(initialTabIndex: 1),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('View My Tickets'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
