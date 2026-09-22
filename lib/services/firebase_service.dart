import 'package:firebase_database/firebase_database.dart';
import '../models/showtime.dart';
import '../models/booking.dart';

class FirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Duration for temporary seat holds (7 minutes).
  static const Duration seatHoldDuration = Duration(minutes: 7);

  // ──────────────────────────────────────────────
  // SHOWTIME QUERIES
  // ──────────────────────────────────────────────

  /// Fetches all showtimes for a movie.
  Future<List<Showtime>> getShowtimes(int movieId) async {
    final ref = _db.ref('showtimes');
    final query = ref.orderByChild('movieId').equalTo(movieId);
    final snapshot = await query.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map(
            (e) => Showtime.fromMap(
              e.key.toString(),
              e.value as Map<dynamic, dynamic>,
            ),
          )
          .toList();
    }
    return [];
  }

  /// Fetches only future (active) showtimes for a movie.
  Future<List<Showtime>> getActiveShowtimes(int movieId) async {
    final showtimes = await getShowtimes(movieId);
    final now = DateTime.now();
    return showtimes.where((st) => st.time.isAfter(now)).toList();
  }

  Future<Showtime?> getShowtime(String showtimeId) async {
    final ref = _db.ref('showtimes/$showtimeId');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      return Showtime.fromMap(
        showtimeId,
        snapshot.value as Map<dynamic, dynamic>,
      );
    }
    return null;
  }

  // ──────────────────────────────────────────────
  // SEAT HOLD (TEMPORARY LOCK)
  // ──────────────────────────────────────────────

  /// Temporarily hold seats for a user. Writes to seatHolds/{showtimeId}/{seatId}.
  Future<void> holdSeats({
    required String showtimeId,
    required List<String> seats,
    required String userId,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(seatHoldDuration);
    final holdsRef = _db.ref('seatHolds/$showtimeId');

    final updates = <String, dynamic>{};
    for (final seat in seats) {
      updates[seat] = {
        'userId': userId,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
      };
    }
    await holdsRef.update(updates);
  }

  /// Release held seats for a user.
  Future<void> releaseSeats({
    required String showtimeId,
    required List<String> seats,
    required String userId,
  }) async {
    final holdsRef = _db.ref('seatHolds/$showtimeId');

    for (final seat in seats) {
      final seatRef = holdsRef.child(seat);
      final snapshot = await seatRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        // Only release if this user owns the hold
        if (data['userId'] == userId) {
          await seatRef.remove();
        }
      }
    }
  }

  /// Remove all expired seat holds for a showtime.
  Future<void> cleanExpiredHolds(String showtimeId) async {
    final holdsRef = _db.ref('seatHolds/$showtimeId');
    final snapshot = await holdsRef.get();

    if (!snapshot.exists) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final data = snapshot.value as Map<dynamic, dynamic>;

    for (final entry in data.entries) {
      final holdData = entry.value as Map<dynamic, dynamic>;
      final expiresAt = holdData['expiresAt'] as int? ?? 0;
      if (expiresAt <= now) {
        await holdsRef.child(entry.key.toString()).remove();
      }
    }
  }

  /// Get active (non-expired) seat holds for a showtime, excluding a specific user.
  Future<Map<String, String>> getActiveHolds(
    String showtimeId, {
    String? excludeUserId,
  }) async {
    await cleanExpiredHolds(showtimeId);

    final holdsRef = _db.ref('seatHolds/$showtimeId');
    final snapshot = await holdsRef.get();

    final holds = <String, String>{};
    if (!snapshot.exists) return holds;

    final now = DateTime.now().millisecondsSinceEpoch;
    final data = snapshot.value as Map<dynamic, dynamic>;

    for (final entry in data.entries) {
      final holdData = entry.value as Map<dynamic, dynamic>;
      final expiresAt = holdData['expiresAt'] as int? ?? 0;
      final holdUserId = holdData['userId'] as String? ?? '';

      if (expiresAt > now && holdUserId != excludeUserId) {
        holds[entry.key.toString()] = holdUserId;
      }
    }
    return holds;
  }

  // ──────────────────────────────────────────────
  // BOOKING (ATOMIC TRANSACTION)
  // ──────────────────────────────────────────────

  /// Book seats using an atomic Firebase transaction.
  Future<void> bookSeats({
    required String showtimeId,
    required String userId,
    required String movieTitle,
    required List<String> selectedSeats,
    required double totalPrice,
    required String posterPath,
    required String cinemaName,
    required String format,
    required DateTime time,
  }) async {
    final showtimeRef = _db.ref('showtimes/$showtimeId/bookedSeats');

    // Use transaction for atomicity
    final result = await showtimeRef.runTransaction((currentData) {
      List<String> currentBooked = [];
      if (currentData != null) {
        currentBooked = List<String>.from(currentData as List);
      }

      // Check if any selected seat is already booked
      for (String seat in selectedSeats) {
        if (currentBooked.contains(seat)) {
          return Transaction.abort();
        }
      }

      // Add new seats
      currentBooked.addAll(selectedSeats);
      return Transaction.success(currentBooked);
    });

    if (!result.committed) {
      throw Exception('ที่นั่งบางตำแหน่งถูกจองไปแล้ว กรุณาเลือกที่นั่งใหม่');
    }

    // Save the booking record
    final bookingRef = _db.ref('bookings').push();
    final booking = Booking(
      id: bookingRef.key!,
      userId: userId,
      showtimeId: showtimeId,
      movieTitle: movieTitle,
      seats: selectedSeats,
      totalPrice: totalPrice,
      timestamp: DateTime.now(),
      posterPath: posterPath,
      cinemaName: cinemaName,
      format: format,
      time: time,
      status: BookingStatus.confirmed,
    );

    await bookingRef.set(booking.toMap());

    // Clean up seat holds for this user
    await releaseSeats(
      showtimeId: showtimeId,
      seats: selectedSeats,
      userId: userId,
    );
  }

  // ──────────────────────────────────────────────
  // BOOKING QUERIES & MANAGEMENT
  // ──────────────────────────────────────────────

  Future<List<Booking>> getUserBookings(String userId) async {
    final ref = _db.ref('bookings');
    final query = ref.orderByChild('userId').equalTo(userId);
    final snapshot = await query.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      print('DEBUG RAW FIREBASE BOOKINGS: $data');
      final bookings = data.entries.map((e) {
        print('DEBUG PARSING BOOKING ${e.key}: ${e.value}');
        return Booking.fromMap(
          e.key.toString(),
          e.value as Map<dynamic, dynamic>,
        );
      }).toList();

      // Auto-update status for past bookings still marked as confirmed
      for (final booking in bookings) {
        if (booking.status == BookingStatus.confirmed &&
            booking.time.isBefore(DateTime.now())) {
          await updateBookingStatus(booking.id, BookingStatus.completed);
        }
      }

      // Sort: upcoming first (by showtime), then past (by showtime desc)
      bookings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return bookings;
    }
    return [];
  }

  /// Update the status of a booking.
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final ref = _db.ref('bookings/$bookingId');
    await ref.update({'status': status.toValue()});
  }

  /// Cancel a booking: update status and release seats.
  Future<void> cancelBooking({
    required String bookingId,
    required String showtimeId,
    required List<String> seats,
  }) async {
    // Update booking status to cancelled
    await updateBookingStatus(bookingId, BookingStatus.cancelled);

    // Remove seats from showtime's bookedSeats using transaction
    final showtimeRef = _db.ref('showtimes/$showtimeId/bookedSeats');
    await showtimeRef.runTransaction((currentData) {
      if (currentData == null) return Transaction.success(currentData);

      final currentBooked = List<String>.from(currentData as List);
      currentBooked.removeWhere((seat) => seats.contains(seat));
      return Transaction.success(currentBooked);
    });
  }

  // ──────────────────────────────────────────────
  // MOCK DATA SEEDING
  // ──────────────────────────────────────────────

  /// Helper method to seed data for testing.
  /// Generates showtimes for today + next 6 days (7 total) to match date selector.
  Future<void> generateMockShowtimes(
    int movieId,
    String movieTitle,
    String posterPath,
  ) async {
    // Only generate if none exist to prevent duplicates
    final existing = await getShowtimes(movieId);
    if (existing.isNotEmpty) return;

    final ref = _db.ref('showtimes');
    final now = DateTime.now();

    // Generate showtimes for today and next 6 days (7 total)
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));

      // Cinema 1: 2D
      for (int hour in [10, 13, 16, 19]) {
        final stRef = ref.push();
        final st = Showtime(
          id: stRef.key!,
          movieId: movieId,
          cinemaName: 'SF Cinema City',
          time: DateTime(date.year, date.month, date.day, hour, 30),
          price: 180.0,
          format: '2D',
          posterPath: posterPath,
          bookedSeats: [],
        );
        await stRef.set(st.toMap());
      }

      // Cinema 2: IMAX
      for (int hour in [11, 15, 20]) {
        final stRef = ref.push();
        final st = Showtime(
          id: stRef.key!,
          movieId: movieId,
          cinemaName: 'IMAX Theatre',
          time: DateTime(date.year, date.month, date.day, hour, 0),
          price: 350.0,
          format: 'IMAX 3D',
          posterPath: posterPath,
          bookedSeats: ['E5', 'E6'], // Randomly pre-book some seats
        );
        await stRef.set(st.toMap());
      }
    }
  }
  // ──────────────────────────────────────────────
  // USER SETTINGS
  // ──────────────────────────────────────────────

  /// Save notification preferences to Firebase.
  Future<void> saveNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    await _db.ref('userSettings/$userId/notifications').update(settings);
  }

  /// Load notification preferences from Firebase.
  Future<Map<String, dynamic>?> getNotificationSettings(String userId) async {
    final ref = _db.ref('userSettings/$userId/notifications');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  /// Save user preferences (e.g. language) to Firebase.
  Future<void> saveUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    await _db.ref('userSettings/$userId/preferences').update(preferences);
  }

  /// Load user preferences from Firebase.
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    final ref = _db.ref('userSettings/$userId/preferences');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
