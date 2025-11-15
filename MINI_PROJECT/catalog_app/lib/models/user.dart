import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? photoURL;
  final String role;
  final String plan;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.username,
    this.photoURL,
    this.role = 'user',
    this.plan = 'Free',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() ?? {}) as Map<String, dynamic>;
    final planFromDoc = (data['plan'] as String?)?.trim();
    final inferredPlan = planFromDoc?.isNotEmpty == true
        ? planFromDoc!
        : (data['role'] == 'vip'
            ? 'VIP'
            : (data['premium'] == true ? 'Premium' : 'Free'));

    final legacyName = data['name'] as String?;

    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      firstName: (data['firstName'] as String?) ?? legacyName,
      lastName: data['lastName'] as String?,
      username: data['username'] as String?,
      photoURL: (data['photoURL'] ?? data['photoUrl']) as String?,
      role: (data['role'] as String?)?.toLowerCase() ?? 'user',
      plan: inferredPlan,
    );
  }

  factory UserModel.guest() {
    return const UserModel(
      uid: 'guest',
      email: 'guest@guest.com',
      displayName: 'Guest',
      role: 'guest',
      plan: 'Free',
    );
  }

  String get fullName {
    final buffer = <String>[];
    if ((firstName ?? '').isNotEmpty) buffer.add(firstName!.trim());
    if ((lastName ?? '').isNotEmpty) buffer.add(lastName!.trim());
    return buffer.join(' ');
  }

  String get preferredName {
    if ((displayName ?? '').trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if ((username ?? '').trim().isNotEmpty) {
      return username!.trim();
    }
    if ((email ?? '').trim().isNotEmpty) {
      return email!.split('@').first;
    }
    return 'User';
  }

  bool get isVip => plan.toLowerCase() == 'vip';
  bool get isPremium => plan.toLowerCase() == 'premium';
  bool get hasPaidPlan => isVip || isPremium;

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? username,
    String? photoURL,
    String? role,
    String? plan,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      plan: plan ?? this.plan,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'photoURL': photoURL,
      'role': role,
      'plan': plan,
      'premium': isPremium || isVip,
    };
  }
}
