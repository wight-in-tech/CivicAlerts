
import 'package:civicalerts/apis/comment_api.dart';
import 'package:civicalerts/core/utils.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentControllerProvider =
StateNotifierProvider<CommentController, bool>((ref) {
  return CommentController(
    ref: ref,
    commentAPI: ref.watch(commentAPIProvider),
  );
});

final fetchReplyCountProvider =
FutureProvider.family<int, String>((ref, repliedToId) async {
  final replyCount = await ref
      .watch(commentControllerProvider.notifier)
      .fetchReplyCount(repliedToId);
  return replyCount;
});

final getCommentsProvider = Provider((ref) {
  final commentController =
  ref.watch(commentControllerProvider.notifier).getComments();
  return commentController;
});

final getCommentsForPostProvider =
FutureProvider.family((ref, String postId) {
  final commentController = ref.watch(commentControllerProvider.notifier);
  return commentController.getCommentsForPost(postId);
});

final getLatestCommentsProvider = Provider((ref) {
  final commentAPI = ref.watch(commentAPIProvider);
  return commentAPI.getLatestComments();
});

class CommentController extends StateNotifier<bool> {
  final Ref _ref;
  final CommentAPI _commentAPI;

  CommentController({required Ref ref, required CommentAPI commentAPI})
      : _ref = ref,
        _commentAPI = commentAPI,
        super(false);

  Future<List<CommentModel>> getComments() async {
    final commentList = await _commentAPI.getComments();
    return commentList
        .map((commentModel) => CommentModel.fromMap(commentModel.data))
        .toList();
  }

  Future<List<CommentModel>> getCommentsForPost(String postId) async {
    final commentList = await _commentAPI.getComments();
    return commentList
        .map((commentModel) => CommentModel.fromMap(commentModel.data))
        .where((comment) => comment.repliedTo == postId)
        .toList();
  }

  void uploadComment({
    required String commentText,
    required BuildContext context,
    required String repliedTo,
  }) {
    if (commentText.isEmpty) {
      ShowSnakBar(context,'Please Enter the Post');
    } else {
      _uploadComment(
        commentText: commentText,
        context: context,
        repliedTo: repliedTo,
      );
    }
  }

  void _uploadComment({
    required String commentText,
    required BuildContext context,
    required String repliedTo,
  }) async {
    state = true;
    final user = _ref.watch(currentUserDetailsProvider).value!;
    CommentModel comment = CommentModel(
      commentText: commentText,
      uid: user.uid,
      commentedAt: DateTime.now(),
      repliedTo: repliedTo,
    );
    final res = await _commentAPI.uploadComments(comment);
    state = false;
    res.fold(
          (l) =>ShowSnakBar(context, l.message),
      // (r) => null,
          (r) => Navigator.pop(context),
    );
  }

  Future<int> fetchReplyCount(String repliedTo) async {
    final replyCount = await _commentAPI.getReplyCount(repliedTo);
    return replyCount;
  }
}