import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_model.dart';
import '../models/child_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  String get _parentsCollection => 'parents';
  String get _childrenCollection => 'children';
  String get _screenTimeCollection => 'screenTime';
  String get _settingsCollection => 'settings';

  // PARENT OPERATIONS
  
  // Get parent data
  Future<ParentModel?> getParent(String parentId) async {
    try {
      DocumentSnapshot doc = await _db.collection(_parentsCollection).doc(parentId).get();
      
      if (doc.exists) {
        return ParentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Error getting parent data: ${e.toString()}');
    }
  }

  // Update parent data
  Future<void> updateParent(String parentId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection(_parentsCollection).doc(parentId).update(data);
    } catch (e) {
      throw FirestoreException('Error updating parent data: ${e.toString()}');
    }
  }

  // CHILDREN OPERATIONS

  // Add a new child
  Future<String> addChild(ChildModel child) async {
    try {
      DocumentReference docRef = await _db.collection(_childrenCollection).add(child.toMap());
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Error adding child: ${e.toString()}');
    }
  }

  // Get all children for a parent
  Future<List<ChildModel>> getChildren(String parentId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(_childrenCollection)
          .where('parentId', isEqualTo: parentId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ChildModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException('Error getting children: ${e.toString()}');
    }
  }

  // Stream of children (real-time updates)
  Stream<List<ChildModel>> getChildrenStream(String parentId) {
    return _db
        .collection(_childrenCollection)
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChildModel.fromFirestore(doc))
            .toList());
  }

  // Get a specific child
  Future<ChildModel?> getChild(String childId) async {
    try {
      DocumentSnapshot doc = await _db.collection(_childrenCollection).doc(childId).get();
      
      if (doc.exists) {
        return ChildModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Error getting child data: ${e.toString()}');
    }
  }

  // Update child data
  Future<void> updateChild(String childId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection(_childrenCollection).doc(childId).update(data);
    } catch (e) {
      throw FirestoreException('Error updating child: ${e.toString()}');
    }
  }

  // Delete a child
  Future<void> deleteChild(String childId) async {
    try {
      // Delete child document
      await _db.collection(_childrenCollection).doc(childId).delete();
      
      // Delete all screen time records for this child
      QuerySnapshot screenTimeRecords = await _db
          .collection(_screenTimeCollection)
          .where('childId', isEqualTo: childId)
          .get();
      
      WriteBatch batch = _db.batch();
      for (DocumentSnapshot doc in screenTimeRecords.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Error deleting child: ${e.toString()}');
    }
  }

  // SCREEN TIME OPERATIONS

  // Add screen time record
  Future<void> addScreenTimeRecord({
    required String childId,
    required String date, // YYYY-MM-DD format
    required int totalMinutes,
    required Map<String, dynamic> appUsage,
  }) async {
    try {
      // Create unique document ID using childId and date
      String docId = '${childId}_$date';
      
      await _db.collection(_screenTimeCollection).doc(docId).set({
        'childId': childId,
        'date': date,
        'totalMinutes': totalMinutes,
        'appUsage': appUsage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Error adding screen time record: ${e.toString()}');
    }
  }

  // Get screen time data for a child
  Future<List<Map<String, dynamic>>> getScreenTimeData({
    required String childId,
    required int days, // Number of days to fetch
  }) async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: days));
      
      QuerySnapshot querySnapshot = await _db
          .collection(_screenTimeCollection)
          .where('childId', isEqualTo: childId)
          .where('date', isGreaterThanOrEqualTo: _formatDate(startDate))
          .where('date', isLessThanOrEqualTo: _formatDate(endDate))
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'date': doc['date'],
                'totalMinutes': doc['totalMinutes'],
                'appUsage': doc['appUsage'],
              })
          .toList();
    } catch (e) {
      throw FirestoreException('Error getting screen time data: ${e.toString()}');
    }
  }

  // Get today's screen time for a child
  Future<Map<String, dynamic>?> getTodayScreenTime(String childId) async {
    try {
      String today = _formatDate(DateTime.now());
      String docId = '${childId}_$today';
      
      DocumentSnapshot doc = await _db.collection(_screenTimeCollection).doc(docId).get();
      
      if (doc.exists) {
        return {
          'totalMinutes': doc['totalMinutes'] ?? 0,
          'appUsage': doc['appUsage'] ?? {},
        };
      }
      
      return {
        'totalMinutes': 0,
        'appUsage': {},
      };
    } catch (e) {
      throw FirestoreException('Error getting today\'s screen time: ${e.toString()}');
    }
  }

  // SETTINGS OPERATIONS

  // Get parent settings
  Future<Map<String, dynamic>> getParentSettings(String parentId) async {
    try {
      DocumentSnapshot doc = await _db.collection(_settingsCollection).doc(parentId).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        // Return default settings
        Map<String, dynamic> defaultSettings = {
          'notifications': true,
          'dailyReports': true,
          'blockAds': true,
          'contentFilters': ['adult_content', 'violence', 'gambling'],
          'nightMode': false,
          'reportFrequency': 'daily', // daily, weekly, monthly
        };
        
        // Create default settings document
        await _db.collection(_settingsCollection).doc(parentId).set({
          ...defaultSettings,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return defaultSettings;
      }
    } catch (e) {
      throw FirestoreException('Error getting settings: ${e.toString()}');
    }
  }

  // Update parent settings
  Future<void> updateParentSettings(String parentId, Map<String, dynamic> settings) async {
    try {
      settings['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection(_settingsCollection).doc(parentId).set(
        settings,
        SetOptions(merge: true),
      );
    } catch (e) {
      throw FirestoreException('Error updating settings: ${e.toString()}');
    }
  }

  // ANALYTICS AND REPORTS

  // Get weekly screen time summary for all children
  Future<Map<String, dynamic>> getWeeklyScreenTimeSummary(String parentId) async {
    try {
      // Get all children
      List<ChildModel> children = await getChildren(parentId);
      
      Map<String, dynamic> summary = {};
      
      for (ChildModel child in children) {
        List<Map<String, dynamic>> weekData = await getScreenTimeData(
          childId: child.id!,
          days: 7,
        );
        
        int totalWeekMinutes = weekData.fold(
          0,
          (sum, day) => sum + (day['totalMinutes'] as int),
        );
        
        summary[child.id!] = {
          'childName': child.name,
          'totalWeekMinutes': totalWeekMinutes,
          'dailyAverage': (totalWeekMinutes / 7).round(),
          'dailyData': weekData,
        };
      }
      
      return summary;
    } catch (e) {
      throw FirestoreException('Error getting weekly summary: ${e.toString()}');
    }
  }

  // Search and filter methods
  Future<List<ChildModel>> searchChildren(String parentId, String searchTerm) async {
    try {
      List<ChildModel> allChildren = await getChildren(parentId);
      
      return allChildren.where((child) {
        return child.name.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    } catch (e) {
      throw FirestoreException('Error searching children: ${e.toString()}');
    }
  }

  // Utility methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Batch operations for better performance
  Future<void> batchUpdateChildren(List<Map<String, dynamic>> updates) async {
    try {
      WriteBatch batch = _db.batch();
      
      for (Map<String, dynamic> update in updates) {
        String childId = update['id'];
        Map<String, dynamic> data = update['data'];
        data['updatedAt'] = FieldValue.serverTimestamp();
        
        DocumentReference docRef = _db.collection(_childrenCollection).doc(childId);
        batch.update(docRef, data);
      }
      
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Error batch updating children: ${e.toString()}');
    }
  }
}

// Custom exception for Firestore errors
class FirestoreException implements Exception {
  final String message;
  FirestoreException(this.message);
  
  @override
  String toString() => 'FirestoreException: $message';
}