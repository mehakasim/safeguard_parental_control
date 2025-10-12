// lib/services/screen_time_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScreenTimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _trackingTimer;
  DateTime? _sessionStartTime;
  String? _currentChildId;

  // Start tracking screen time for a child
  void startTracking(String childId) {
    if (_trackingTimer != null) {
      stopTracking();
    }

    _currentChildId = childId;
    _sessionStartTime = DateTime.now();

    // Update screen time every minute
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateScreenTime();
      print('Updating screen time');
    });
  }

  // Stop tracking screen time
  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    
    if (_currentChildId != null && _sessionStartTime != null) {
      _updateScreenTime();
    }
    
    _currentChildId = null;
    _sessionStartTime = null;
  }

  // Update screen time in Firestore
  Future<void> _updateScreenTime() async {
    if (_currentChildId == null) return;

    try {
      await _firestore.collection('children').doc(_currentChildId).set({
        'screenTime': FieldValue.increment(1),
        'lastActivityAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating screen time: $e');
    }
  }

  // Get current screen time for a child
  Future<Map<String, dynamic>> getScreenTimeData(String childId) async {
    try {
      final doc = await _firestore.collection('children').doc(childId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'screenTime': data['screenTime'] ?? 0,
          'screenTimeLimit': data['screenTimeLimit'] ?? 120,
          'lastActivityAt': data['lastActivityAt'],
        };
      }
    } catch (e) {
      print('Error getting screen time data: $e');
    }
    
    return {
      'screenTime': 0,
      'screenTimeLimit': 120,
      'lastActivityAt': null,
    };
  }

  // Check if child has exceeded their limit
  Future<bool> hasExceededLimit(String childId) async {
    final data = await getScreenTimeData(childId);
    return (data['screenTime'] as int) >= (data['screenTimeLimit'] as int);
  }

  // Reset screen time for a child
  Future<void> resetScreenTime(String childId) async {
    try {
      await _firestore.collection('children').doc(childId).set({
        'screenTime': 0,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error resetting screen time: $e');
    }
  }

  // Reset screen time for all children
  Future<void> resetAllChildrenScreenTime(String parentId) async {
    try {
      final children = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: parentId)
          .get();

      final batch = _firestore.batch();
      
      for (var doc in children.docs) {
        batch.set(doc.reference, {
          'screenTime': 0,
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Error resetting all screen times: $e');
    }
  }

  // Add manual screen time (for parent adjustments)
  Future<void> addScreenTime(String childId, int minutes) async {
    try {
      await _firestore.collection('children').doc(childId).set({
        'screenTime': FieldValue.increment(minutes),
        'lastActivityAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding screen time: $e');
    }
  }

  // Update screen time limit
  Future<void> updateScreenTimeLimit(String childId, int limitMinutes) async {
    try {
      await _firestore.collection('children').doc(childId).set({
        'screenTimeLimit': limitMinutes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating screen time limit: $e');
    }
  }

  // Get screen time history for analytics
  Stream<DocumentSnapshot> streamScreenTime(String childId) {
    return _firestore.collection('children').doc(childId).snapshots();
  }

  // Dispose resources
  void dispose() {
    stopTracking();
  }
}