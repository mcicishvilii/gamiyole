import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPost {
  final String id;
  final String authorId;
  final String authorRole;
  final String origin;
  final String destination;
  final String status;
  final int priceOffer;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int seatsNeeded;

  TravelPost({
    required this.id,
    required this.authorId,
    required this.authorRole,
    required this.origin,
    required this.destination,
    required this.status,
    required this.priceOffer,
    required this.departureDate,
    this.returnDate,
    required this.seatsNeeded,
  });

  factory TravelPost.fromMap(Map<String, dynamic> data, String id) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final departure = parseDate(data['departureDate']) ?? DateTime.now();

    return TravelPost(
      id: id,
      authorId: data['authorId'] ?? '',
      authorRole: data['authorRole'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      status: data['status'] ?? 'open',
      priceOffer: data['priceOffer'] is int
          ? data['priceOffer'] as int
          : (data['priceOffer'] is double
              ? (data['priceOffer'] as double).round()
              : 0),
      departureDate: departure,
      returnDate: parseDate(data['returnDate']),
      seatsNeeded: data['seatsNeeded'] is int
          ? data['seatsNeeded'] as int
          : 1,
    );
  }
}
