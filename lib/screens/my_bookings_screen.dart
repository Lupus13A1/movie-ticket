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
          _errorMessage = 'Please login to view bookings';
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
          _errorMessage = 'Failed to load bookings';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes', style: TextStyle(color: AppTheme.error)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      try {
        if (!mounted) return;
        await context.read<FirebaseService>().cancelBooking(
          bookingId: booking.id,
          showtimeId: booking.showtimeId,
          seats: booking.seats,
        );
        await _fetchBookings();
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to cancel booking';
          });
        }
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppTheme.foreground,
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color badgeColor;
    Color badgeTextColor;
    String badgeText;
    bool isUpcoming = booking.effectiveStatus == BookingStatus.confirmed;

    if (isUpcoming) {
      badgeColor = Colors.green.withOpacity(0.2);
      badgeTextColor = Colors.green;
      badgeText = 'Upcoming';
    } else if (booking.effectiveStatus == BookingStatus.completed) {
      badgeColor = AppTheme.surface;
      badgeTextColor = AppTheme.mutedForeground;
      badgeText = 'Completed';
    } else {
      badgeColor = AppTheme.error.withOpacity(0.2);
      badgeTextColor = AppTheme.error;
      badgeText = 'Cancelled';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POSTER
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: SizedBox(
              width: 100,
              height: 150,
              child: booking.posterPath.isNotEmpty
                  ? Image.network(
                      '${Constants.tmdbImageBaseUrl}${booking.posterPath}',
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.background,
                      child: const Icon(
                        Icons.movie,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
            ),
          ),

          // DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.movieTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(booking.time)} • ${DateFormat('HH:mm').format(booking.time)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.cinemaName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Seats: ${booking.seats.join(', ')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foreground,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isUpcoming) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _cancelBooking(booking),
                        child: const Text(
                          'Cancel Booking',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
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
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: AppTheme.foreground),
        ),
      );
    }

    if (_bookings == null || _bookings!.isEmpty) {
      return const Center(
        child: Text(
          'No tickets booked yet.',
          style: TextStyle(fontSize: 16, color: AppTheme.mutedForeground),
        ),
      );
    }

    final upcoming = _bookings!
        .where((b) => b.effectiveStatus == BookingStatus.confirmed)
        .toList();
    final completed = _bookings!
        .where((b) => b.effectiveStatus == BookingStatus.completed)
        .toList();
    final cancelled = _bookings!
        .where((b) => b.effectiveStatus == BookingStatus.cancelled)
        .toList();

    upcoming.sort((a, b) => a.time.compareTo(b.time));
    completed.sort((a, b) => b.time.compareTo(a.time));
    cancelled.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final listItems = <Widget>[];

    // Extra padding at top for transparent appbar if used in bottom nav
    listItems.add(const SizedBox(height: 48));

    if (upcoming.isNotEmpty) {
      listItems.add(_buildSectionHeader('Upcoming Showtimes'));
      listItems.addAll(upcoming.map((b) => _buildBookingCard(b)));
    }

    if (completed.isNotEmpty) {
      listItems.add(_buildSectionHeader('Past Showtimes'));
      listItems.addAll(completed.map((b) => _buildBookingCard(b)));
    }

    if (cancelled.isNotEmpty) {
      listItems.add(_buildSectionHeader('Cancelled'));
      listItems.addAll(cancelled.map((b) => _buildBookingCard(b)));
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: listItems,
      ),
    );
  }
}
