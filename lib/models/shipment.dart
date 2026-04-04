class Shipment {
  final String id;
  final String senderId;
  final String origin;
  final String destination;
  final double budget;
  final String status;

  Shipment({required this.id, required this.senderId, required this.origin, required this.destination, required this.budget, required this.status});

  factory Shipment.fromMap(Map<String, dynamic> data, String id) {
    return Shipment(
      id: id,
      senderId: data['senderId'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      budget: (data['budget'] ?? 0).toDouble(),
      status: data['status'] ?? 'open',
    );
  }
}