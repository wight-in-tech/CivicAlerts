import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:civicalerts/enums/post_type_enum.dart';

@immutable
class Post {
  final String title;
  final String description;
  final String contact;
  final String locationDescription;
  final String location;
  final String uid;
  //final PostType postType;
  final List<String> imageLinks;
  final int createdAt; // Changed from DateTime to int
  final List<String> likes;
  final List<String> commentIds;
  final String id;
  final int reshareCount;

  Post({
    required this.title,
    required this.description,
    required this.contact,
    required this.locationDescription,
    required this.location,
    required this.uid,
    //required this.postType,
    required this.imageLinks,
    required this.createdAt,
    required this.likes,
    required this.commentIds,
    required this.id,
    required this.reshareCount,
  });

  Post copyWith({
    String? title,
    String? description,
    String? contact,
    String? locationDescription,
    String? location,
    String? uid,
    //PostType? postType,
    List<String>? imageLinks,
    int? createdAt, // Changed from DateTime to int
    List<String>? likes,
    List<String>? commentIds,
    String? id,
    int? reshareCount,
  }) {
    return Post(
      title: title ?? this.title,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      locationDescription: locationDescription ?? this.locationDescription,
      location: location ?? this.location,
      uid: uid ?? this.uid,
      // postType: postType ?? this.postType,
      imageLinks: imageLinks ?? this.imageLinks,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentIds: commentIds ?? this.commentIds,
      id: id ?? this.id,
      reshareCount: reshareCount ?? this.reshareCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'contact': contact,
      'locationDescription': locationDescription,
      'location': location,
      'uid': uid,
      //'postType': postType.type,
      'imageLinks': imageLinks,
      'createdAt': createdAt, // Now directly use the integer value
      'likes': likes,
      'commentIds': commentIds,
      'reshareCount': reshareCount,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    T cast<T>(String k) => map[k] is T
        ? map[k] as T
        : throw ArgumentError.value(map[k], k, '$T ← ${map[k].runtimeType}');

    return Post(
      title: cast<String>('title'),
      description: cast<String>('description'),
      contact: cast<String>('contact'),
      locationDescription: cast<String>('locationDescription'),
      location: cast<String>('location'),
      uid: cast<String>('uid'),
      //postType: PostType.fromMap(Map.from(cast<Map>('postType'))),
      imageLinks: List<String>.from(cast<Iterable>('imageLinks')),
      createdAt: cast<num>('createdAt').toInt(), // Parse as integer
      likes: List<String>.from(cast<Iterable>('likes')),
      commentIds: List<String>.from(cast<Iterable>('commentIds')),
      id: map['\$id'] ?? '',
      reshareCount: cast<num>('reshareCount').toInt(),
    );
  }

  @override
  String toString() {
    return 'Post(title: $title, description: $description, contact: $contact, locationDescription: $locationDescription, location: $location, uid: $uid, imageLinks: $imageLinks, createdAt: $createdAt, likes: $likes, commentIds: $commentIds, id: $id, reshareCount: $reshareCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.title == title &&
        other.description == description &&
        other.contact == contact &&
        other.locationDescription == locationDescription &&
        other.location == location &&
        other.uid == uid &&
        // other.postType == postType &&
        listEquals(other.imageLinks, imageLinks) &&
        other.createdAt == createdAt &&
        listEquals(other.likes, likes) &&
        listEquals(other.commentIds, commentIds) &&
        other.id == id &&
        other.reshareCount == reshareCount;
  }

  @override
  int get hashCode {
    return title.hashCode ^
    description.hashCode ^
    contact.hashCode ^
    locationDescription.hashCode ^
    location.hashCode ^
    uid.hashCode ^
    //postType.hashCode ^
    imageLinks.hashCode ^
    createdAt.hashCode ^
    likes.hashCode ^
    commentIds.hashCode ^
    id.hashCode ^
    reshareCount.hashCode;
  }
}