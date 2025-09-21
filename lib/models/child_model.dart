import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String? id;
  final String name;
  final String email;
  final int age;
  final String parentId;
  final String? profilePicture;
  final int screenTimeLimit; // in minutes
  final List<String> restrictions;
  final bool isActive;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChildModel({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.parentId,
    this.profilePicture,
    this.screenTimeLimit = 120, // default 2 hours
    this.restrictions = const [],
    this.isActive = true,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'parentId': parentId,
      'profilePicture': profilePicture,
      'screenTimeLimit': screenTimeLimit,
      'restrictions': restrictions,
      'isActive': isActive,
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : FieldValue.serverTimestamp(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory ChildModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ChildModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      parentId: data['parentId'] ?? '',
      profilePicture: data['profilePicture'],
      screenTimeLimit: data['screenTimeLimit'] ?? 120,
      restrictions: List<String>.from(data['restrictions'] ?? []),
      isActive: data['isActive'] ?? true,
      lastActiveAt: data['lastActiveAt'] != null 
          ? (data['lastActiveAt'] as Timestamp).toDate() 
          : null,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Create from Map
  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      parentId: map['parentId'] ?? '',
      profilePicture: map['profilePicture'],
      screenTimeLimit: map['screenTimeLimit'] ?? 120,
      restrictions: List<String>.from(map['restrictions'] ?? []),
      isActive: map['isActive'] ?? true,
      lastActiveAt: map['lastActiveAt'] != null ? DateTime.parse(map['lastActiveAt']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Copy with method
  ChildModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? parentId,
    String? profilePicture,
    int? screenTimeLimit,
    List<String>? restrictions,
    bool? isActive,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      parentId: parentId ?? this.parentId,
      profilePicture: profilePicture ?? this.profilePicture,
      screenTimeLimit: screenTimeLimit ?? this.screenTimeLimit,
      restrictions: restrictions ?? this.restrictions,
      isActive: isActive ?? this.isActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for screen time
  String get screenTimeLimitFormatted {
    final hours = screenTimeLimit ~/ 60;
    final minutes = screenTimeLimit % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Helper method to check if child has specific restriction
  bool hasRestriction(String restrictionId) {
    return restrictions.contains(restrictionId);
  }

  // Helper method to get restriction display names
  List<String> get restrictionDisplayNames {
    const restrictionMap = {
      'adult_content': 'Adult Content',
      'social_media': 'Social Media',
      'gaming': 'Gaming',
      'shopping': 'Online Shopping',
      'violence': 'Violence',
      'ads': 'Advertisements',
    };
    
    return restrictions.map((id) => restrictionMap[id] ?? id).toList();
  }

  // Age-based helper methods
  bool get isToddler => age >= 3 && age <= 5;
  bool get isChild => age >= 6 && age <= 12;
  bool get isTeenager => age >= 13 && age <= 18;

  String get ageGroup {
    if (isToddler) return 'Toddler';
    if (isChild) return 'Child';
    if (isTeenager) return 'Teenager';
    return 'Unknown';
  }

  // Get recommended screen time based on age
  int get recommendedScreenTime {
    if (age >= 3 && age <= 5) return 60; // 1 hour for toddlers
    if (age >= 6 && age <= 12) return 120; // 2 hours for children
    if (age >= 13 && age <= 15) return 180; // 3 hours for young teens
    if (age >= 16 && age <= 18) return 240; // 4 hours for older teens
    return 120; // default
  }

  // Get recommended restrictions based on age
  List<String> get recommendedRestrictions {
    if (age >= 3 && age <= 8) {
      return ['adult_content', 'violence', 'social_media', 'shopping', 'ads'];
    } else if (age >= 9 && age <= 12) {
      return ['adult_content', 'violence', 'shopping', 'ads'];
    } else if (age >= 13 && age <= 15) {
      return ['adult_content', 'violence', 'shopping'];
    } else {
      return ['adult_content', 'violence'];
    }
  }

  // To JSON string
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'parentId': parentId,
      'profilePicture': profilePicture,
      'screenTimeLimit': screenTimeLimit,
      'restrictions': restrictions,
      'isActive': isActive,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ChildModel{id: $id, name: $name, age: $age, parentId: $parentId, screenTimeLimit: $screenTimeLimit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}