import 'dart:io';

import 'package:civicalerts/Theme/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void ShowSnakBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content,
  ),
  backgroundColor: scaffoldMessengerColor,));
}

String GetnamefromEmail(String email) {
  return email.split('@').first;
}

Future<List<File>> PickImages() async {
  List<File> images = [];
  final ImagePicker picker = ImagePicker();
  final imageFiles = await picker.pickMultiImage();
  if (imageFiles.isNotEmpty) {
    for (final image in imageFiles) {
      images.add(File(image.path));
    }
  }
  return images;
}
Future<bool> requestLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false; // Location services are disabled
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false; // Permissions are denied
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false; // Permissions are permanently denied
  }

  return true; // Permissions are granted
}

void showLocationPermissionSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Center(
        child: Text(
          'Location permission is required to submit complaints.',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: scaffoldMessengerColor,
    ),
  );
}

void showLocationErrorSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Center(
        child: Text(
          'Unable to get current location. Please try again.',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor:scaffoldMessengerColor,
    ),
  );
}

LatLng stringToLatLng(String locationString) {
  List<String> latLng = locationString.split(',');
  return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: scaffoldMessengerColor,
    ),
  );
}

Future<File?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final imageFile = await picker.pickImage(source: ImageSource.gallery);
  if (imageFile != null) {
    return File(imageFile.path);
  }
  return null;
}