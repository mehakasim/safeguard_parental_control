// lib/utils/content_filter.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentFilter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _blockedWords = [];

  /// Load blocked words from Firestore collection `blocked_words`.
  /// Each document is expected to have a field named "word".
  Future<void> loadBlockedWords() async {
    try {
      final snapshot = await _firestore.collection('blocked_words').get();
      _blockedWords = snapshot.docs
          .map((doc) => (doc.data()['word'] ?? '').toString().toLowerCase())
          .where((w) => w.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error loading blocked words: $e');
      _blockedWords = [];
    }
  }

  /// Check text for blocked words using word-boundary safe matching.
  bool containsBlockedWords(String text) {
    if (text.isEmpty || _blockedWords.isEmpty) return false;
    final lower = text.toLowerCase();

    for (final word in _blockedWords) {
      // use RegExp.escape to avoid regex special chars in blocked words
      final pattern =
          RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (pattern.hasMatch(lower)) return true;
    }
    return false;
  }

  /// Expose current blocked words (optional)
  List<String> get blockedWords => List.unmodifiable(_blockedWords);
}
