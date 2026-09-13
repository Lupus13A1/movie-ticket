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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SUCCESS ICON
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.foreground,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: AppTheme.foreground, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 80,
                    color: AppTheme.background,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // SUCCESS TEXT
              const Text(
                'BOOKING CONFIRMED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontDisplay,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: AppTheme.foreground,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),

              // TICKET DETAILS
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.foreground, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      movieTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(time).toUpperCase()} • ${DateFormat('HH:mm').format(time)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cinemaName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SEATS: ${seats.join(', ')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TOTAL: ฿${totalPrice.toInt()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // BUTTONS
              SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialTabIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'VIEW MY TICKETS',
                    style: TextStyle(
                      fontFamily: AppTheme.fontMono,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'BACK TO HOME',
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
      ),
    );
  }
}
