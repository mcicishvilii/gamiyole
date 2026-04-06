import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/travel_post.dart';

class ShipmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<TravelPost> _senderPosts = [];
  List<TravelPost> _travelerPosts = [];
  List<TravelPost> _myPosts = [];
  
  List<TravelPost> get senderPosts => _senderPosts;
  List<TravelPost> get travelerPosts => _travelerPosts;
  List<TravelPost> get myPosts => _myPosts;

  void fetchTravelPosts({String? currentUserId}) {
    _db
        .collection('travel_posts')
        .where('status', isEqualTo: 'open')
        .where('authorRole', isEqualTo: 'sender')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _senderPosts = snapshot.docs
              .map((doc) => TravelPost.fromMap(doc.data(), doc.id))
              .where((post) => post.authorId != currentUserId)
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
              .where((post) => post.authorId != currentUserId)
              .toList();
          notifyListeners();
        });
  }

  void fetchMyPosts(String userId) {
    _db
        .collection('travel_posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _myPosts = snapshot.docs
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
}