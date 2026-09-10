import 'package:firebase_database/firebase_database.dart';
import '../models/showtime.dart';
import '../models/booking.dart';

class FirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Since we are mocking showtimes for the mini-project, we will just fetch all
  // and filter by movieId on the client side, or query by movieId.
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
    final showtimeRef = _db.ref('showtimes/$showtimeId');
    final bookingRef = _db.ref('bookings').push();

    // Read current booked seats
    final snapshot = await showtimeRef.child('bookedSeats').get();
    List<String> currentBooked = [];
    if (snapshot.exists && snapshot.value != null) {
      currentBooked = List<String>.from(snapshot.value as List);
    }

    // Check if any selected seat is already booked
    for (String seat in selectedSeats) {
      if (currentBooked.contains(seat)) {
        throw Exception('ที่นั่ง $seat ถูกจองไปแล้ว');
      }
    }

    // Add new seats and write back
    currentBooked.addAll(selectedSeats);
    await showtimeRef.child('bookedSeats').set(currentBooked);

    // Save the booking record
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
    );

    await bookingRef.set(booking.toMap());
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final ref = _db.ref('bookings');
    final query = ref.orderByChild('userId').equalTo(userId);
    final snapshot = await query.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map(
            (e) => Booking.fromMap(
              e.key.toString(),
              e.value as Map<dynamic, dynamic>,
            ),
          )
          .toList()
        ..sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        ); // Sort latest first
    }
    return [];
  }

  // Helper method to seed data for testing
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

    // Generate showtimes for today and next 3 days
    for (int dayOffset = 0; dayOffset < 4; dayOffset++) {
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
}
