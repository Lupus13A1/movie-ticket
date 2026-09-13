enum BookingStatus {
  confirmed,
  completed,
  cancelled;

  String toValue() => name;

  static BookingStatus fromValue(String? value) {
    switch (value) {
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'confirmed':
      default:
        return BookingStatus.confirmed;
    }
  }
}

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
  final BookingStatus status;

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
    this.status = BookingStatus.confirmed,
  });

  /// Whether this booking is for an upcoming showtime and still confirmed.
  bool get isUpcoming =>
      status == BookingStatus.confirmed && time.isAfter(DateTime.now());

  /// Whether the showtime has passed (regardless of stored status).
  bool get isPast => time.isBefore(DateTime.now());

  /// Whether this booking was cancelled.
  bool get isCancelled => status == BookingStatus.cancelled;

  /// The effective status — auto-detects completed if showtime has passed.
  BookingStatus get effectiveStatus {
    if (status == BookingStatus.cancelled) return BookingStatus.cancelled;
    if (time.isBefore(DateTime.now())) return BookingStatus.completed;
    return BookingStatus.confirmed;
  }

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
      status: BookingStatus.fromValue(map['status']),
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
      'status': status.toValue(),
    };
  }
}
