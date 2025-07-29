
import 'package:civicalerts/features/posts/controller/comment_controller.dart';
import 'package:civicalerts/features/posts/widgets/comment_card.dart';
import 'package:civicalerts/features/posts/widgets/post_reply_view_card.dart';
import 'package:civicalerts/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Constants/appwriteconstants.dart';
import '../../../models/post_model.dart';

class PostReplyView extends ConsumerWidget {
  static route(Post post) => MaterialPageRoute(
      builder: (context) => PostReplyView(
        post: post,
      ));
  final Post post;
  PostReplyView({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostReplyViewCard(post: post),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  'Comments',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Gilroy',
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CommentList( postId: post.id,),
            ],
          ),
        ),
      ),

    );
  }
}

class CommentList extends ConsumerWidget {
  final String postId;

  const CommentList({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getCommentsForPostProvider(postId)).when(
      data: (initialComments) {
        return StreamBuilder(
          stream: ref.watch(getLatestCommentsProvider),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final realtimeData = snapshot.data!;
              if (realtimeData.events.contains(
                'databases.*.collections.${AppwriteConstants.commentsCollections}.documents.*.create',
              )) {
                final newComment =
                CommentModel.fromMap(realtimeData.payload);
                if (newComment.repliedTo == postId) {
                  initialComments.insert(0, newComment);
                }
              } else if (realtimeData.events.contains(
                'databases.*.collections.${AppwriteConstants.commentsCollections}.documents.*.update',
              )) {
                final startingPoint =
                realtimeData.events[0].lastIndexOf('documents.');
                final endPoint =
                realtimeData.events[0].lastIndexOf('.update');
                final commentId = realtimeData.events[0]
                    .substring(startingPoint + 10, endPoint);

                final commentIndex = initialComments.indexWhere(
                        (comment) => comment.repliedTo == commentId);
                if (commentIndex != -1) {
                  initialComments[commentIndex] =
                      CommentModel.fromMap(realtimeData.payload);
                }
              }
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: initialComments.length,
              itemBuilder: (context, index) {
                return CommentCard(comment: initialComments[index]);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}