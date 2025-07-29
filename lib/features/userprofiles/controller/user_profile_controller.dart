import 'dart:io';
import 'package:civicalerts/apis/post_api.dart';
import 'package:civicalerts/apis/user_api.dart';
import 'package:civicalerts/core/utils.dart';
import 'package:civicalerts/enums/notification_type_enum.dart';
import 'package:civicalerts/features/notifications/controller/notification_controller.dart';
import 'package:civicalerts/models/post_model.dart';
import 'package:civicalerts/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/storage_api.dart';

final userProfileControllerProvider =
StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    postAPI: ref.watch(PostApiProvider),
    storageAPI: ref.watch(storageApiProvider),
    userAPI: ref.watch(userApiProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final getUserPostsProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
  ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserPosts(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userApiProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final PostApi _postAPI;
  final StorageApi _storageAPI;
  final UserApi _userAPI;
  final NotificationController _notificationController;
  UserProfileController({
    required PostApi postAPI,
    required StorageApi storageAPI,
    required UserApi userAPI,
    required NotificationController notificationController,
  })  : _postAPI = postAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Post>> getUserPosts(String uid) async {
    final posts = await _postAPI.getUserPosts(uid);
    return posts.map((e) => Post.fromMap(e.data)).toList();
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,

    required File? profileFile,
  }) async {
    state = true;


    if (profileFile != null) {
      final profileUrl = await _storageAPI.uploadImages([profileFile]);
      userModel = userModel.copyWith(
        profilePic: profileUrl[0],
      );
    }

    final res = await _userAPI.updateUserData(userModel);
    state = false;
    res.fold(
          (l) => showErrorSnackBar(context, l.message),
          (r) => Navigator.pop(context),
    );
  }

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    // already following
    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.remove(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(
      following: currentUser.following,
    );

    final res = await _userAPI.followUser(user);
    res.fold((l) => showErrorSnackBar(context, l.message), (r) async {
      final res2 = await _userAPI.addToFollowing(currentUser);
      res2.fold((l) => showErrorSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
          text: '${currentUser.name} followed you!',
          postId: '',
          notificationType: NotificationType.follow,
          uid: user.uid,
        );
      });
    });
  }
}