class Showtime {
  final String id;
  final int movieId;
  final String cinemaName;
  final DateTime time;
  final double price;
  final List<String> bookedSeats;

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaName,
    required this.time,
    required this.price,
    this.bookedSeats = const [],
  });

  factory Showtime.fromMap(String id, Map<dynamic, dynamic> map) {
    return Showtime(
      id: id,
      movieId: map['movieId'] ?? 0,
      cinemaName: map['cinemaName'] ?? '',
      time: DateTime.tryParse(map['time'] ?? '') ?? DateTime.now(),
      price: (map['price'] ?? 0).toDouble(),
      bookedSeats: List<String>.from(map['bookedSeats'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'cinemaName': cinemaName,
      'time': time.toIso8601String(),
      'price': price,
      'bookedSeats': bookedSeats,
    };
  }
}
