// import 'package:flutter/foundation.dart';
//
// @immutable
// class UserModel {
//   final String email;
//   final String name;
//   final List<String> followers;
//   final List<String> following;
//   final String profilePic;
//   final String uid;
//   final String mobileNo;
//   final bool isVerified;
//
//   const UserModel({
//     required this.email,
//     required this.name,
//     required this.followers,
//     required this.following,
//     required this.profilePic,
//     required this.uid,
//     required this.mobileNo,
//     required this.isVerified,
//   });
//
//   UserModel copyWith({
//     String? email,
//     String? name,
//     List<String>? followers,
//     List<String>? following,
//     String? profilePic,
//     String? mobileNo,
//     String? uid,
//     bool? isVerified,
//   }) {
//     return UserModel(
//       email: email ?? this.email,
//       name: name ?? this.name,
//       followers: followers ?? this.followers,
//       following: following ?? this.following,
//       profilePic: profilePic ?? this.profilePic,
//       mobileNo: mobileNo ?? this.mobileNo,
//       uid: uid ?? this.uid,
//       isVerified: isVerified ?? this.isVerified,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};
//
//     result.addAll({'email': email});
//     result.addAll({'name': name});
//     result.addAll({'followers': followers});
//     result.addAll({'following': following});
//     result.addAll({'profilePic': profilePic});
//     result.addAll({'mobileNo': mobileNo});
//     result.addAll({'uid': uid});
//     result.addAll({'isVerified': isVerified});
//
//     return result;
//   }
//
//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       email: map['email'] ?? '',
//       name: map['name'] ?? '',
//       followers: List<String>.from(map['followers']),
//       following: List<String>.from(map['following']),
//       profilePic: map['profilePic'] ?? '',
//       mobileNo: map['mobileNo'] ?? '',
//       uid: map['\$id'] ?? '',
//       isVerified: map['isVerified'] ?? false,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'UserModel(email: $email, name: $name, followers: $followers, following: $following, profilePic: $profilePic, mobileNo: $mobileNo, uid: $uid, isVerified: $isVerified)';
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//
//     return other is UserModel &&
//         other.email == email &&
//         other.name == name &&
//         listEquals(other.followers, followers) &&
//         listEquals(other.following, following) &&
//         other.profilePic == profilePic &&
//         other.mobileNo == mobileNo &&
//         other.uid == uid &&
//         other.isVerified == isVerified;
//   }
//
//   @override
//   int get hashCode {
//     return email.hashCode ^
//         name.hashCode ^
//         followers.hashCode ^
//         following.hashCode ^
//         profilePic.hashCode ^
//         mobileNo.hashCode ^
//         uid.hashCode ^
//         isVerified.hashCode;
//   }
// }


// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UserModel {
  final String email;
  final String name;
  final String address;
  final List<String> followers;
  final List<String> following;
  final String uid;
  final String profilePic;
  final String mobileNo;
  final bool isVerified;

  UserModel({
    required this.email,
    required this.name,
    required this.address,
    required this.followers,
    required this.following,
    required this.uid,
    required this.profilePic,
    required this.mobileNo,
    required this.isVerified,
  });

  UserModel copyWith({
    String? email,
    String? name,
    String? address,
    List<String>? followers,
    List<String>? following,
    String? uid,
    String? profilePic,
    String? mobileNo,
    bool? isVerified,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      address: address ?? this.address,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      uid: uid ?? this.uid,
      profilePic: profilePic ?? this.profilePic,
      mobileNo: mobileNo ?? this.mobileNo,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'address': address,
      'followers': followers,
      'following': following,

      'profilePic': profilePic,
      'mobileNo': mobileNo,
      'isVerified': isVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      uid: map['\$id'] ?? '',
      profilePic: map['profilePic'] ?? '',
      mobileNo: map['mobileNo'] ?? '',
      isVerified: map['isVerified'] ?? false,
    );
  }

  @override
  String toString() {
    return 'UserModel(email: $email, name: $name, address: $address, followers: $followers, following: $following, uid: $uid, profilePic: $profilePic, mobileNo: $mobileNo, isVerified: $isVerified)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.email == email &&
        other.name == name &&
        other.address == address &&
        listEquals(other.followers, followers) &&
        listEquals(other.following, following) &&
        other.uid == uid &&
        other.profilePic == profilePic &&
        other.mobileNo == mobileNo &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return email.hashCode ^
    name.hashCode ^
    address.hashCode ^
    followers.hashCode ^
    following.hashCode ^
    uid.hashCode ^
    profilePic.hashCode ^
    mobileNo.hashCode ^
    isVerified.hashCode;
  }
}
