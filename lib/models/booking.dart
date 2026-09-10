class Booking {
  final String id;
  final String userId;
  final String showtimeId;
  final String movieTitle;
  final List<String> seats;
  final double totalPrice;
  final DateTime timestamp;
  final String posterPath;
  final String cinemaName;
  final String format;
  final DateTime time;

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.movieTitle,
    required this.seats,
    required this.totalPrice,
    required this.timestamp,
    required this.posterPath,
    required this.cinemaName,
    required this.format,
    required this.time,
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
      posterPath: map['posterPath'] ?? '',
      cinemaName: map['cinemaName'] ?? '',
      format: map['format'] ?? '2D',
      time: DateTime.tryParse(map['time'] ?? '') ?? DateTime.now(),
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
      'posterPath': posterPath,
      'cinemaName': cinemaName,
      'format': format,
      'time': time.toIso8601String(),
    };
  }
}
