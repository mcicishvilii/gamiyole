import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _appUser;

  AppUser? get appUser => _appUser;
  User? get firebaseUser => _auth.currentUser;

  AuthViewModel() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _appUser = AppUser.fromMap(
          doc.data() as Map<String, dynamic>,
          user.uid,
        );
      } else {
        _appUser = null;
      }
    } else {
      _appUser = null;
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String role) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _appUser = AppUser(uid: result.user!.uid, email: email, role: role);

      notifyListeners();
    } on FirebaseAuthException catch (e, st) {
      debugPrint('FirebaseAuthException: code=${e.code}, message=${e.message}');
      debugPrintStack(stackTrace: st);
      rethrow;
    } on FirebaseException catch (e, st) {
      debugPrint('FirebaseException: code=${e.code}, message=${e.message}');
      debugPrintStack(stackTrace: st);
      rethrow;
    } catch (e, st) {
      debugPrint('Unknown signUp error: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
    _appUser = null;
    notifyListeners();
  }
}
