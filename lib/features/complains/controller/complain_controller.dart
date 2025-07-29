import 'dart:io';
import 'package:civicalerts/apis/complain_api.dart';
import 'package:civicalerts/apis/storage_api.dart';
import 'package:civicalerts/core/utils.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/notifications/controller/notification_controller.dart';
import 'package:civicalerts/models/complain_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ComplainControllerProvider =
StateNotifierProvider<ComplainController, bool>((ref) {
  return ComplainController(
    ref: ref,
    complainApi: ref.watch(ComplainApiProvider),
    storageApi: ref.watch(storageApiProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final GetComplainsProvider = FutureProvider((ref) {
  final controller = ref.watch(ComplainControllerProvider.notifier);
  return controller.getComplains();
});

class ComplainController extends StateNotifier<bool> {
  final Ref ref;
  final ComplainApi _complainApi;
  final StorageApi _storageApi;
  final NotificationController _notificationController;

  ComplainController({
    required this.ref,
    required ComplainApi complainApi,
    required StorageApi storageApi,
    required NotificationController notificationController,
  })  : _complainApi = complainApi,
        _storageApi = storageApi,
        _notificationController = notificationController,
        super(false);

  Future<List<Complain>> getComplains() async {
    final complainDocs = await _complainApi.getComplains();
    return complainDocs.map((doc) => Complain.fromMap(doc.data)).toList();
  }

  void shareComplain({
    required List<File> images,
    required String title,
    required String description,
    required String contact,
    required String locationDescription,
    required String location,
    required BuildContext context,
  }) {
    _shareComplain(
      images: images,
      title: title.trim(),
      description: description.trim(),
      contact: contact.trim(),
      location: location.trim(),
      context: context,
      locationDescription: locationDescription.trim(),
    );
  }

  Future<void> _shareComplain({
    required List<File> images,
    required String title,
    required String description,
    required String locationDescription,
    required String contact,
    required String location,
    required BuildContext context,
  }) async {
    state = true;

    try {
      final user = ref.read(currentUserDetailsProvider).value;

      if (user == null) {
        showErrorSnackBar(context, 'User not authenticated. Please log in again.');
        state = false;
        return;
      }

      List<String> imageLinks = [];
      if (images.isNotEmpty) {
        try {
          imageLinks = await _storageApi.uploadImages(images);
        } catch (e) {
          showErrorSnackBar(context, 'Failed to upload images: $e');
          state = false;
          return;
        }
      }

      final complain = Complain(
        title: title,
        description: description,
        contact: contact,
        locationDescription: locationDescription,
        location: location,
        uid: user.uid,
        imageLinks: imageLinks,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: '',
        resolved: false,
      );

      final res = await _complainApi.shareComplain(complain);
      res.fold(
            (failure) {
          showErrorSnackBar(context, failure.message);
        },
            (success) {
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      showErrorSnackBar(context, 'An unexpected error occurred: $e');
    } finally {
      state = false;
    }
  }
}
