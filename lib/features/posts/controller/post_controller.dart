import 'dart:io';
import 'package:civicalerts/Constants/appwriteconstants.dart';
import 'package:civicalerts/apis/post_api.dart';
import 'package:civicalerts/apis/storage_api.dart';
import 'package:civicalerts/core/utils.dart';
import 'package:civicalerts/enums/notification_type_enum.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/notifications/controller/notification_controller.dart';
import 'package:civicalerts/models/post_model.dart';
import 'package:civicalerts/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civicalerts/apis/complain_api.dart';
import 'package:civicalerts/models/complain_model.dart';

final PostControllerProvider =
StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
    ref: ref,
    postApi: ref.watch(PostApiProvider),
    storageApi: ref.watch(storageApiProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
    complainApi: ref.watch(ComplainApiProvider),
  );
});

final GetPostsProvider = FutureProvider((ref) {
  final postController = ref.watch(PostControllerProvider.notifier);
  return postController.getPosts();
});

final getLatestTweetProvider = StreamProvider.autoDispose((ref) {
  final postApi = ref.watch(PostApiProvider);
  return postApi.getLatestPost();
});

class PostController extends StateNotifier<bool> {
  final Ref ref;
  final PostApi _postApi;
  final StorageApi _storageApi;
  final NotificationController _notificationController;
  final ComplainApi _complainApi;

  PostController({
    required this.ref,
    required PostApi postApi,
    required StorageApi storageApi,
    required NotificationController notificationController,
    required ComplainApi complainApi,
  })  : _postApi = postApi,
        _storageApi = storageApi,
        _notificationController = notificationController,
        _complainApi = complainApi,
        super(false);

  Future<List<Post>> getPosts() async {
    final postList = await _postApi.getPosts();
    return postList.map((post) => Post.fromMap(post.data)).toList();
  }

  void likePost(Post post, UserModel user) async {
    try {
      List<String> likes = List.from(post.likes);
      bool isLiking = !likes.contains(user.uid);

      if (likes.contains(user.uid)) {
        likes.remove(user.uid);
      } else {
        likes.add(user.uid);
      }

      final updatedPost = post.copyWith(likes: likes);

      final res = await _postApi.likePost(updatedPost);

      res.fold((failure) {
        print('Like API failed: ${failure.message}');
      }, (success) async {
        // Send like notification
        if (isLiking &&
            updatedPost.uid != user.uid &&
            updatedPost.uid.isNotEmpty) {
          _notificationController.createNotification(
            text: '${user.name} liked your post!',
            postId: updatedPost.id,
            notificationType: NotificationType.like,
            uid: updatedPost.uid,
          );
        }

        // ✅ Convert to complain if threshold met
        final totalInteractions =
            updatedPost.likes.length + updatedPost.commentIds.length;
        if (totalInteractions >= AppwriteConstants.threshold) {
          await _convertPostToComplain(updatedPost);
        }
      });
    } catch (e) {
      print('Error in likePost: $e');
    }
  }

  // Separated method for converting post to complain with notification
  Future<void> _convertPostToComplain(Post post) async {
    try {
      final existingComplains = await _complainApi.getComplains();
      bool alreadyConverted = existingComplains.any((doc) =>
      Complain.fromMap(doc.data).title == post.title &&
          Complain.fromMap(doc.data).uid == post.uid);

      if (!alreadyConverted) {
        final complain = Complain(
          title: post.title,
          description: post.description,
          contact: post.contact,
          locationDescription: post.locationDescription,
          location: post.location,
          uid: post.uid,
          imageLinks: post.imageLinks,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: '',
          resolved: false,
        );

        final complainRes = await _complainApi.shareComplain(complain);
        complainRes.fold(
              (failure) =>
              print('Failed to convert to complain: ${failure.message}'),
              (success) {
            print('Post converted to complain successfully');

            // 🎉 Send notification to post author about conversion
            _notificationController.createNotification(
              text: 'Great news! Your post "${_truncateText(post.title, 30)}" has gained enough attention and has been converted to an official complain for faster resolution!',
              postId: post.id,
              notificationType: NotificationType.complain, // You'll need to add this enum
              uid: post.uid,
            );

            // Optional: Send notification to all users who liked the post
            _notifyPostEngagers(post, success);
          },
        );
      }
    } catch (e) {
      print('Error converting post to complain: $e');
    }
  }

  // Helper method to notify users who engaged with the post
  void _notifyPostEngagers(Post post, dynamic complainData) async {
    try {
      // Notify all users who liked the post (except the author)
      for (String likerUid in post.likes) {
        if (likerUid != post.uid) {
          _notificationController.createNotification(
            text: 'A post you liked "${_truncateText(post.title, 30)}" has been converted to an official complain!',
            postId: post.id,
            notificationType: NotificationType.complain,
            uid: likerUid,
          );
        }
      }
    } catch (e) {
      print('Error notifying post engagers: $e');
    }
  }

  // Helper method to truncate text for notifications
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void sharePost({
    required List<File> images,
    required String title,
    required String description,
    required String contact,
    required String locationDescription,
    required String location,
    required BuildContext context,
  }) {
    // Validate required fields
    if (title.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter a title');
      return;
    }

    if (contact.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter contact information');
      return;
    }

    if (location.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter a location');
      return;
    }

    _sharePost(
      images: images,
      title: title.trim(),
      description: description.trim(),
      contact: contact.trim(),
      location: location.trim(),
      context: context,
      locationDescription: locationDescription.trim(),
    );
  }

  Future<void> _sharePost({
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
        showErrorSnackBar(
            context, 'User not authenticated. Please log in again.');
        state = false;
        return;
      }

      // Upload images if any
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

      final post = Post(
        title: title,
        description: description,
        contact: contact,
        locationDescription: locationDescription,
        location: location,
        uid: user.uid,
        imageLinks: imageLinks,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        likes: [],
        commentIds: [],
        id: '',
        reshareCount: 0,
      );

      final res = await _postApi.sharePost(post);
      res.fold((failure) {
        showErrorSnackBar(context, failure.message);
      }, (success) {
        // Show success message and navigate back
        Navigator.of(context).pop();
      });
    } catch (e) {
      showErrorSnackBar(context, 'An unexpected error occurred: $e');
    } finally {
      state = false;
    }
  }

  void resharePost(
      Post originalPost, UserModel user, BuildContext context) async {
    try {
      state = true;

      // Create a reshare post
      final resharePost = Post(
        title: 'Reshared: ${originalPost.title}',
        description: originalPost.description,
        contact: originalPost.contact,
        locationDescription: originalPost.locationDescription,
        location: originalPost.location,
        uid: user.uid,
        imageLinks: originalPost.imageLinks,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        likes: [],
        commentIds: [],
        id: '',
        reshareCount: 0,
      );

      final res = await _postApi.sharePost(resharePost);
      res.fold((failure) {
        showErrorSnackBar(context, failure.message);
      }, (success) {
        // Update original post's reshare count
        final updatedOriginalPost = originalPost.copyWith(
          reshareCount: originalPost.reshareCount + 1,
        );
        _postApi.likePost(updatedOriginalPost);

        // Send notification to original post author
        if (originalPost.uid != user.uid && originalPost.uid.isNotEmpty) {
          _notificationController.createNotification(
            text: '${user.name} reshared your post!',
            postId: originalPost.id,
            notificationType: NotificationType.like,
            uid: originalPost.uid,
          );
        }
      });
    } catch (e) {
      showErrorSnackBar(context, 'Failed to reshare post: $e');
    } finally {
      state = false;
    }
  }

  void deletePost(String postId, BuildContext context) async {
    // Implementation for delete post
  }
}