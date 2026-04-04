import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/travel_post.dart';

class ShipmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<TravelPost> _senderPosts = [];
  List<TravelPost> _travelerPosts = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _senderSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _travelerSubscription;

  List<TravelPost> get senderPosts => _senderPosts;
  List<TravelPost> get travelerPosts => _travelerPosts;

  void fetchTravelPosts() {
    _senderSubscription?.cancel();
    _travelerSubscription?.cancel();

    _senderSubscription = _db
        .collection('travel_posts')
        .where('status', isEqualTo: 'open')
        .where('authorRole', isEqualTo: 'sender')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
          print(
            '[SENDER_QUERY] '
            'count=${snapshot.docs.length} '
            'fromCache=${snapshot.metadata.isFromCache} '
            'pendingWrites=${snapshot.metadata.hasPendingWrites}',
          );

          for (final d in snapshot.docs) {
            print(
              '[SENDER_DOC] '
              'docId=${d.id} '
              'origin=${d.data()['origin']} '
              'dest=${d.data()['destination']}',
            );
          }

          _senderPosts = snapshot.docs
              .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
              .toList();

          print(
            '[STATE] senderPosts=${_senderPosts.length}, '
            'travelerPosts=${_travelerPosts.length}',
          );

          notifyListeners();
        });

    _travelerSubscription = _db
        .collection('travel_posts')
        .where('status', isEqualTo: 'open')
        .where('authorRole', isEqualTo: 'traveler')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
          print(
            '[TRAVELER_QUERY] '
            'count=${snapshot.docs.length} '
            'fromCache=${snapshot.metadata.isFromCache} '
            'pendingWrites=${snapshot.metadata.hasPendingWrites}',
          );

          for (final d in snapshot.docs) {
            print(
              '[TRAVELER_DOC] '
              'docId=${d.id} '
              'origin=${d.data()['origin']} '
              'dest=${d.data()['destination']}',
            );
          }

          _travelerPosts = snapshot.docs
              .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
              .toList();

          print(
            '[STATE] senderPosts=${_senderPosts.length}, '
            'travelerPosts=${_travelerPosts.length}',
          );

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

  @override
  void dispose() {
    _senderSubscription?.cancel();
    _travelerSubscription?.cancel();
    super.dispose();
  }
}