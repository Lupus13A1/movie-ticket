import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../constants.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking>? _bookings;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final user = context.read<AuthService>().user;
      if (user == null) {
        setState(() {
          _errorMessage = 'PLEASE LOGIN TO VIEW BOOKINGS';
          _isLoading = false;
        });
        return;
      }

      final firebaseService = context.read<FirebaseService>();
      final bookings = await firebaseService.getUserBookings(user.uid);

      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'FAILED TO LOAD BOOKINGS';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.foreground, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POSTER
          Container(
            width: 100,
            height: 150,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppTheme.foreground, width: 2),
              ),
              color: AppTheme.muted,
            ),
            child: booking.posterPath.isNotEmpty
                ? Image.network(
                    '${Constants.tmdbImageBaseUrl}${booking.posterPath}',
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.movie, color: AppTheme.mutedForeground),
          ),

          // DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.movieTitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontDisplay,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(booking.time).toUpperCase()} • ${DateFormat('HH:mm').format(booking.time)}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.cinemaName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'SEATS: ${booking.seats.join(', ')}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontMono,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: AppTheme.foreground,
                        child: const Text(
                          'CONFIRMED',
                          style: TextStyle(
                            fontFamily: AppTheme.fontMono,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.background,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.foreground),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            fontFamily: AppTheme.fontMono,
            color: AppTheme.foreground,
          ),
        ),
      );
    }

    if (_bookings == null || _bookings!.isEmpty) {
      return const Center(
        child: Text(
          'NO BOOKINGS YET',
          style: TextStyle(
            fontFamily: AppTheme.fontMono,
            fontSize: 16,
            color: AppTheme.mutedForeground,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: AppTheme.background,
      backgroundColor: Colors.transparent,
      child: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _bookings!.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(_bookings![index]);
        },
      ),
    );
  }
}
