import 'package:flutter/foundation.dart';

@immutable
class Complain {
  final String title;
  final String description;
  final String contact;
  final String locationDescription;
  final String location;
  final String uid;
  final List<String> imageLinks;
  final int createdAt;
  final String id;
  final bool resolved;

  Complain({
    required this.title,
    required this.description,
    required this.contact,
    required this.locationDescription,
    required this.location,
    required this.uid,
    required this.imageLinks,
    required this.createdAt,
    required this.id,
    required this.resolved,
  });

  Complain copyWith({
    String? title,
    String? description,
    String? contact,
    String? locationDescription,
    String? location,
    String? uid,
    List<String>? imageLinks,
    int? createdAt,
    String? id,
    bool? resolved,
  }) {
    return Complain(
      title: title ?? this.title,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      locationDescription: locationDescription ?? this.locationDescription,
      location: location ?? this.location,
      uid: uid ?? this.uid,
      imageLinks: imageLinks ?? this.imageLinks,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      resolved: resolved ?? this.resolved,
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
      'imageLinks': imageLinks,
      'createdAt': createdAt,
      'resolved': resolved,
    };
  }

  factory Complain.fromMap(Map<String, dynamic> map) {
    T cast<T>(String key) {
      final value = map[key];
      if (value is T) return value;
      throw ArgumentError.value(value, key, 'Expected type $T');
    }

    return Complain(
      title: cast<String>('title'),
      description: cast<String>('description'),
      contact: cast<String>('contact'),
      locationDescription: cast<String>('locationDescription'),
      location: cast<String>('location'),
      uid: cast<String>('uid'),
      imageLinks: List<String>.from(cast<Iterable>('imageLinks')),
      createdAt: cast<num>('createdAt').toInt(),
      id: map['\$id'] ?? '',
      resolved: cast<bool>('resolved'),
    );
  }

  @override
  String toString() {
    return 'Complain(title: $title, description: $description, contact: $contact, locationDescription: $locationDescription, location: $location, uid: $uid, imageLinks: $imageLinks, createdAt: $createdAt, id: $id, resolved: $resolved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Complain &&
        other.title == title &&
        other.description == description &&
        other.contact == contact &&
        other.locationDescription == locationDescription &&
        other.location == location &&
        other.uid == uid &&
        listEquals(other.imageLinks, imageLinks) &&
        other.createdAt == createdAt &&
        other.id == id &&
        other.resolved == resolved;
  }

  @override
  int get hashCode {
    return title.hashCode ^
    description.hashCode ^
    contact.hashCode ^
    locationDescription.hashCode ^
    location.hashCode ^
    uid.hashCode ^
    imageLinks.hashCode ^
    createdAt.hashCode ^
    id.hashCode ^
    resolved.hashCode;
  }
}
