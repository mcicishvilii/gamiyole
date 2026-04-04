import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/shipment.dart';

class ShipmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Shipment> _shipments = [];

  List<Shipment> get shipments => _shipments;

  void fetchShipments() {
    _db
        .collection('shipments')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((snapshot) {
          _shipments = snapshot.docs
              .map((doc) => Shipment.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });
  }

  Future<void> createTestShipment() async {
    try {
      await _db.collection('shipments').add({
        'senderId': 'test_user_123',
        'origin': 'Tbilisi',
        'destination': 'Batumi',
        'budget': 25.0,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Shipment added successfully!");
    } catch (e) {
      print("Error adding shipment: $e");
    }
  }

  Future<void> placeBid(
    String shipmentId,
    String travelerId,
    double price,
  ) async {
    await _db.collection('shipments').doc(shipmentId).collection('offers').add({
      'travelerId': travelerId,
      'price': price,
      'status': 'sent',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
