import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  void initializeAuthStateListener(Function(User?) onAuthChanged) {
    _auth.authStateChanges().listen((User? user) {
      onAuthChanged(user);
    });
  }

  // Register with email and password
  Future<UserModel> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw Exception('Connection timed out. Check your internet.'),
        );

    final user = UserModel(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
    );

    await Future.wait([
      _firestore.collection('users').doc(user.uid).set(user.toMap()),
      credential.user!.updateDisplayName(displayName),
    ]);

    return user;
  }

  // Login with email and password
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw Exception('Connection timed out. Check your internet.'),
        );

    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception('Could not load profile. Try again.'),
        );

    return UserModel.fromMap(doc.data()!);
  }

  // Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign-In cancelled');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential).timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw Exception('Connection timed out. Check your internet.'),
        );

    final firebaseUser = userCredential.user!;
    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) {
      final user = UserModel(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'Google User',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    }

    return UserModel.fromMap(doc.data()!);
  }

  // Facebook Sign-In
  Future<UserModel> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status != LoginStatus.success) {
      throw Exception('Facebook Sign-In cancelled or failed');
    }

    final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);

    final userCredential = await _auth.signInWithCredential(credential).timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw Exception('Connection timed out. Check your internet.'),
        );

    final firebaseUser = userCredential.user!;
    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) {
      final user = UserModel(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'Facebook User',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    }

    return UserModel.fromMap(doc.data()!);
  }

  // Get user profile
  Future<UserModel> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception('Could not load profile. Try again.'),
        );
    return UserModel.fromMap(doc.data()!);
  }

  // Update display name
  Future<void> updateDisplayName(String uid, String newName) async {
    await Future.wait([
      _firestore.collection('users').doc(uid).update({'displayName': newName}),
      _auth.currentUser!.updateDisplayName(newName),
    ]);
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _auth.signOut();
  }

  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
}
