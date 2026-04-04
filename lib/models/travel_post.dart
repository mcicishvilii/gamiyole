class TravelPost {
  final String id;
  final String authorId;
  final String authorRole;
  final String origin;
  final String destination;
  final String status;

  TravelPost({
    required this.id,
    required this.authorId,
    required this.authorRole,
    required this.origin,
    required this.destination,
    required this.status,
  });

  factory TravelPost.fromMap(Map<String, dynamic> data, String id) {
    return TravelPost(
      id: id,
      authorId: data['authorId'] ?? '',
      authorRole: data['authorRole'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      status: data['status'] ?? 'open',
    );
  }
}
