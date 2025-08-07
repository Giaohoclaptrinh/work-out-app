import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add notification for user
  Future<void> addNotification(
    String title,
    String message, {
    String? type,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
            'title': title,
            'message': message,
            'type': type ?? 'general',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  // Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications({
    int limit = 10,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Add activity for user
  Future<void> addActivity(
    String title,
    String description, {
    String? type,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .add({
            'title': title,
            'description': description,
            'type': type ?? 'general',
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding activity: $e');
    }
  }

  // Get user activities
  Future<List<Map<String, dynamic>>> getUserActivities({int limit = 10}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting activities: $e');
      return [];
    }
  }

  // Format time ago
  static String formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    try {
      final DateTime time = timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
