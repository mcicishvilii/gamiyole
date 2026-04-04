import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/shipment.dart';
import '../models/travel_post.dart';

class ShipmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Shipment> _shipments = [];
  List<TravelPost> _senderPosts = [];
  List<TravelPost> _travelerPosts = [];

  List<Shipment> get shipments => _shipments;
  List<TravelPost> get senderPosts => _senderPosts;
  List<TravelPost> get travelerPosts => _travelerPosts;

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

  void fetchTravelPosts() {
    _db
        .collection('travel_posts')
        .where('status', isEqualTo: 'open')
        .where('authorRole', isEqualTo: 'sender')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _senderPosts = snapshot.docs
              .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });

    _db
        .collection('travel_posts')
        .where('status', isEqualTo: 'open')
        .where('authorRole', isEqualTo: 'traveler')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _travelerPosts = snapshot.docs
              .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });
  }

  Future<void> createTravelerPost({
    required String travelerId,
    required String origin,
    required String destination,
  }) async {
    await _db.collection('travel_posts').add({
      'authorId': travelerId,
      'authorRole': 'traveler',
      'origin': origin,
      'destination': destination,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createSenderPost({
    required String senderId,
    required String origin,
    required String destination,
  }) async {
    await _db.collection('travel_posts').add({
      'authorId': senderId,
      'authorRole': 'sender',
      'origin': origin,
      'destination': destination,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
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
      print('Shipment added successfully!');
    } catch (e) {
      print('Error adding shipment: $e');
    }
  }

  Future<void> placeBid(String shipmentId, String travelerId, double price) async {
    await _db.collection('shipments').doc(shipmentId).collection('offers').add({
      'travelerId': travelerId,
      'price': price,
      'status': 'sent',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
