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

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: AppTheme.foreground, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          title: const Text(
            'CANCEL BOOKING',
            style: TextStyle(
              fontFamily: AppTheme.fontDisplay,
              color: AppTheme.foreground,
            ),
          ),
          content: const Text(
            'ARE YOU SURE YOU WANT TO CANCEL THIS BOOKING?',
            style: TextStyle(
              fontFamily: AppTheme.fontMono,
              color: AppTheme.foreground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'NO',
                style: TextStyle(
                  fontFamily: AppTheme.fontMono,
                  color: AppTheme.foreground,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'YES',
                style: TextStyle(
                  fontFamily: AppTheme.fontMono,
                  color: Colors.red,
                ),
              ),
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
            _errorMessage = 'FAILED TO CANCEL BOOKING';
          });
        }
      }
    }
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color badgeColor;
    Color badgeTextColor;
    String badgeText;
    bool isUpcoming = booking.effectiveStatus == BookingStatus.confirmed;

    if (isUpcoming) {
      badgeColor = Colors.green;
      badgeTextColor = AppTheme.background;
      badgeText = 'UPCOMING';
    } else if (booking.effectiveStatus == BookingStatus.completed) {
      badgeColor = AppTheme.muted;
      badgeTextColor = AppTheme.mutedForeground;
      badgeText = 'COMPLETED';
    } else {
      badgeColor = Colors.red;
      badgeTextColor = AppTheme.background;
      badgeText = 'CANCELLED';
    }

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
                        color: badgeColor,
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontFamily: AppTheme.fontMono,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isUpcoming) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _cancelBooking(booking),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontFamily: AppTheme.fontMono,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
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

    if (upcoming.isNotEmpty) {
      listItems.add(_buildSectionHeader('UPCOMING', Colors.green));
      listItems.addAll(upcoming.map((b) => _buildBookingCard(b)));
    }

    if (completed.isNotEmpty) {
      listItems.add(_buildSectionHeader('COMPLETED', AppTheme.muted));
      listItems.addAll(completed.map((b) => _buildBookingCard(b)));
    }

    if (cancelled.isNotEmpty) {
      listItems.add(_buildSectionHeader('CANCELLED', Colors.red));
      listItems.addAll(cancelled.map((b) => _buildBookingCard(b)));
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: AppTheme.background,
      backgroundColor: Colors.transparent,
      child: ListView(padding: const EdgeInsets.all(24.0), children: listItems),
    );
  }
}
