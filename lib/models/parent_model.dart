import 'package:cloud_firestore/cloud_firestore.dart';

class ParentModel {
  final String? id;
  final String name;
  final String email;
  final String? profilePicture;
  final bool emailVerified;
  final int childrenCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParentModel({
    this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.emailVerified = false,
    this.childrenCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'emailVerified': emailVerified,
      'childrenCount': childrenCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory ParentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ParentModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profilePicture'],
      emailVerified: data['emailVerified'] ?? false,
      childrenCount: data['childrenCount'] ?? 0,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Create from Map
  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      emailVerified: map['emailVerified'] ?? false,
      childrenCount: map['childrenCount'] ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Copy with method
  ParentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    bool? emailVerified,
    int? childrenCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      emailVerified: emailVerified ?? this.emailVerified,
      childrenCount: childrenCount ?? this.childrenCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // To JSON string
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'emailVerified': emailVerified,
      'childrenCount': childrenCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ParentModel{id: $id, name: $name, email: $email, childrenCount: $childrenCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}