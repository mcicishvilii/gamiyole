import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/shipment.dart';
import '../models/travel_post.dart';

class ShipmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Shipment> _shipments = [];
  List<TravelPost> _senderPosts = [];
  List<TravelPost> _travelerPosts = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _shipmentsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _senderPostsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _travelerPostsSub;

  List<Shipment> get shipments => _shipments;
  List<TravelPost> get senderPosts => _senderPosts;
  List<TravelPost> get travelerPosts => _travelerPosts;

  void fetchShipments() {
    _shipmentsSub?.cancel();

    final query = _db.collection('shipments').where('status', isEqualTo: 'open');
    _shipmentsSub = query.snapshots(includeMetadataChanges: true).listen(
      (snapshot) {
        _shipments = snapshot.docs
            .map((doc) => Shipment.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();

        if (snapshot.metadata.isFromCache) {
          _refreshShipmentsFromServer(query);
        }
      },
      onError: (error) {
        debugPrint('SHIPMENTS_QUERY_ERROR: $error');
      },
    );
  }

  void fetchTravelPosts() {
    _senderPostsSub?.cancel();
    _travelerPostsSub?.cancel();

    final senderQuery = _db
        .collection('travel_posts')
        .where('status', isEqualTo: 'open')
        .where('authorRole', isEqualTo: 'sender')
        .orderBy('createdAt', descending: true);

    _senderPostsSub = senderQuery.snapshots(includeMetadataChanges: true).listen(
      (snapshot) {
        _senderPosts = snapshot.docs
            .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();

        if (snapshot.metadata.isFromCache) {
          _refreshSenderPostsFromServer(senderQuery);
        }
      },
      onError: (error) {
        debugPrint('SENDER_QUERY_ERROR: $error');
      },
    );

    final travelerQuery = _db
        .collection('travel_posts')
        .where('status', isEqualTo: 'open')
        .where('authorRole', isEqualTo: 'traveler')
        .orderBy('createdAt', descending: true);

    _travelerPostsSub = travelerQuery
        .snapshots(includeMetadataChanges: true)
        .listen(
      (snapshot) {
        _travelerPosts = snapshot.docs
            .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();

        if (snapshot.metadata.isFromCache) {
          _refreshTravelerPostsFromServer(travelerQuery);
        }
      },
      onError: (error) {
        debugPrint('TRAVELER_QUERY_ERROR: $error');
      },
    );
  }

  Future<void> _refreshShipmentsFromServer(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      final serverSnapshot = await query.get(const GetOptions(source: Source.server));
      _shipments = serverSnapshot.docs
          .map((doc) => Shipment.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (error) {
      debugPrint('SHIPMENTS_SERVER_REFRESH_ERROR: $error');
    }
  }

  Future<void> _refreshSenderPostsFromServer(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      final serverSnapshot = await query.get(const GetOptions(source: Source.server));
      _senderPosts = serverSnapshot.docs
          .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (error) {
      debugPrint('SENDER_SERVER_REFRESH_ERROR: $error');
    }
  }

  Future<void> _refreshTravelerPostsFromServer(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      final serverSnapshot = await query.get(const GetOptions(source: Source.server));
      _travelerPosts = serverSnapshot.docs
          .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (error) {
      debugPrint('TRAVELER_SERVER_REFRESH_ERROR: $error');
    }
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

  @override
  void dispose() {
    _shipmentsSub?.cancel();
    _senderPostsSub?.cancel();
    _travelerPostsSub?.cancel();
    super.dispose();
  }
}
