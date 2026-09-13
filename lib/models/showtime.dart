class Showtime {
  final String id;
  final int movieId;
  final String cinemaName;
  final DateTime time;
  final double price;
  final List<String> bookedSeats;
  final String format;
  final String posterPath;

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaName,
    required this.time,
    required this.price,
    this.bookedSeats = const [],
    this.format = '2D',
    this.posterPath = '',
  });

  /// Whether this showtime has already passed.
  bool get isPast => time.isBefore(DateTime.now());

  /// Whether this showtime is today.
  bool get isToday {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  /// Whether this showtime is closing soon (less than 30 minutes from now).
  bool get isClosingSoon {
    if (isPast) return false;
    final diff = time.difference(DateTime.now());
    return diff.inMinutes <= 30;
  }

  factory Showtime.fromMap(String id, Map<dynamic, dynamic> map) {
    return Showtime(
      id: id,
      movieId: map['movieId'] ?? 0,
      cinemaName: map['cinemaName'] ?? '',
      time: DateTime.tryParse(map['time'] ?? '') ?? DateTime.now(),
      price: (map['price'] ?? 0).toDouble(),
      bookedSeats: List<String>.from(map['bookedSeats'] ?? []),
      format: map['format'] ?? '2D',
      posterPath: map['posterPath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'cinemaName': cinemaName,
      'time': time.toIso8601String(),
      'price': price,
      'bookedSeats': bookedSeats,
      'format': format,
      'posterPath': posterPath,
    };
  }
}
