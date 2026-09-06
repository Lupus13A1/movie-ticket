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
  }) async {
    final showtimeRef = _db.ref('showtimes/$showtimeId');
    final bookingRef = _db.ref('bookings').push();

    // Use transaction to avoid double booking
    final transactionResult = await showtimeRef.runTransaction((Object? post) {
      if (post == null) {
        return Transaction.abort();
      }

      Map<dynamic, dynamic> showtimeData = Map<dynamic, dynamic>.from(
        post as Map,
      );
      List<dynamic> bookedSeats = showtimeData['bookedSeats'] != null
          ? List<dynamic>.from(showtimeData['bookedSeats'])
          : [];

      // Check if any selected seat is already booked
      for (String seat in selectedSeats) {
        if (bookedSeats.contains(seat)) {
          return Transaction.abort(); // Seat already booked
        }
      }

      // Add new seats
      bookedSeats.addAll(selectedSeats);
      showtimeData['bookedSeats'] = bookedSeats;

      return Transaction.success(showtimeData);
    });

    if (transactionResult.committed) {
      // If seats successfully booked, save the booking record
      final booking = Booking(
        id: bookingRef.key!,
        userId: userId,
        showtimeId: showtimeId,
        movieTitle: movieTitle,
        seats: selectedSeats,
        totalPrice: totalPrice,
        timestamp: DateTime.now(),
      );

      await bookingRef.set(booking.toMap());
    } else {
      throw Exception('Seats already booked by someone else.');
    }
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
          .toList();
    }
    return [];
  }
}
