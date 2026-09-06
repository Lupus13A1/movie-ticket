class Booking {
  final String id;
  final String userId;
  final String showtimeId;
  final String movieTitle;
  final List<String> seats;
  final double totalPrice;
  final DateTime timestamp;

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.movieTitle,
    required this.seats,
    required this.totalPrice,
    required this.timestamp,
  });

  factory Booking.fromMap(String id, Map<dynamic, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      showtimeId: map['showtimeId'] ?? '',
      movieTitle: map['movieTitle'] ?? '',
      seats: List<String>.from(map['seats'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'showtimeId': showtimeId,
      'movieTitle': movieTitle,
      'seats': seats,
      'totalPrice': totalPrice,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
