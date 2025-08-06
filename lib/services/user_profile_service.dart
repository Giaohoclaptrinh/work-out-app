import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProfileService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Create user profile
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('users')
          .doc(profile.id)
          .update(updatedProfile.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUserProfile(user.uid);
  }

  // Update specific fields in user profile
  Future<void> updateUserProfileFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('users').doc(userId).update(fields);
    } catch (e) {
      throw Exception('Failed to update user profile fields: $e');
    }
  }

  // Stream user profile changes
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Stream current user profile changes
  Stream<UserProfile?> streamCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return streamUserProfile(user.uid);
  }
}
