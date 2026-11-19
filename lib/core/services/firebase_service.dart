import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/booking.dart';
import '../../models/vehicle_type.dart';

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<UserProfile> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _loadProfile(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    } catch (_) {
      throw AuthFailure('Could not sign in. Check your connection and try again.');
    }
  }

  Future<UserProfile> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      final firestoreRole =
          role == UserRole.mechanic ? 'Mechanic' : 'User';

      try {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'id': user.uid,
          'name': name.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          'role': firestoreRole,
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Auth succeeded; a blocked profile write should not lose the session.
      }

      return UserProfile(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role.firestoreValue,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    } catch (_) {
      throw AuthFailure('Could not create your account. Please try again.');
    }
  }

  Future<UserProfile> _loadProfile(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        return UserProfile(
          uid: user.uid,
          name: (data['name'] as String?)?.trim().isNotEmpty == true
              ? data['name'] as String
              : _nameFromEmail(user.email),
          email: (data['email'] as String?) ?? user.email ?? '',
          phone: (data['phone'] as String?) ?? '',
          role: data['role'] == 'Mechanic' ? 'mechanic' : 'customer',
          isPremium: data['isPremium'] == true,
          trialEndsAt: _parseDate(data['trialEndsAt']),
          planLabel: data['planLabel'] as String?,
        );
      }
    } catch (_) {
      // Offline or rules issue: continue with the auth identity.
    }
    return UserProfile(
      uid: user.uid,
      name: _nameFromEmail(user.email),
      email: user.email ?? '',
      phone: '',
      role: 'customer',
    );
  }

  Future<void> saveSubscription({
    required String uid,
    required SubscriptionPlan plan,
    required DateTime activeUntil,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'isPremium': true,
        'planLabel': '${plan.name} (${plan.period.replaceFirst('/', '')})',
        'subscriptionActiveUntil': Timestamp.fromDate(activeUntil),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> saveBooking(String uid, BookingRecord booking) async {
    if (uid.isEmpty) return;
    try {
      await _db.collection('bookings').doc(booking.id).set({
        'uid': uid,
        'title': booking.title,
        'vehicle': booking.vehicle,
        'mechanic': booking.mechanicName,
        'status': booking.status.name,
        'travelFee': booking.travelFee,
        'total': booking.total,
        'method': booking.method?.name,
        'txn': booking.txn,
        'lines': booking.lines
            .map((l) => {
                  'serviceId': l.serviceId,
                  'name': l.name,
                  'amount': l.amount,
                  'done': l.done,
                })
            .toList(),
        'createdAt': Timestamp.fromDate(booking.date),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> sendChatMessage({
    required String bookingId,
    required String text,
    required bool fromCustomer,
  }) async {
    if (bookingId.isEmpty) return;
    try {
      await _db
          .collection('chats')
          .doc(bookingId)
          .collection('messages')
          .add({
        'text': text,
        'fromCustomer': fromCustomer,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> setOnline(String uid, bool online) async {
    if (uid.isEmpty) return;
    try {
      await _db.collection('users').doc(uid).set({
        'isOnline': online,
        'latitude': 23.7925,
        'longitude': 90.4078,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'CarAid user';
    final prefix = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return prefix
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
