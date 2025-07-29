import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/posts/controller/comment_controller.dart';
import 'package:civicalerts/features/posts/controller/post_controller.dart';
import 'package:civicalerts/features/posts/widgets/post_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'lib/Constants/asset_constants.dart';
import '../../../models/post_model.dart';
import '../../../common/error_page.dart';
import '../../../common/loading_page.dart';
import '../views/post_reply_view.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader()
        : ref.watch(UserDetailsProvider(post.uid)).when(
      data: (user) {
        final createdAtDateTime = DateTime.fromMillisecondsSinceEpoch(post.createdAt);

        return GestureDetector(
          onTap: () {
            Navigator.push(context, PostReplyView.route(post));
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1.0, // Square aspect ratio
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with user info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User avatar
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 16,
                        ),

                        const SizedBox(width: 10),

                        // User info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "@${user.name} · ${timeago.format(createdAtDateTime, locale: 'en_short')}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Options menu
                        IconButton(
                          icon: const Icon(Icons.more_horiz, size: 16),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Post content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      post.description,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Media content (expanded to fill remaining space)
                  if (post.imageLinks.isNotEmpty)
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            post.imageLinks[0],
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    )
                  else
                  // If no image, fill the space with a gradient background
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.grey.shade50, Colors.grey.shade100],
                          ),
                        ),
                      ),
                    ),

                  // Bottom interaction bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Views row with avatars
                        Row(
                          children: [
                            // Views count
                            PostIconButton(
                              pathName: AssetsConstants.views,
                              text: (post.likes.length + post.reshareCount + post.commentIds.length).toString(),
                              onTap: () {},
                            ),
                            Text(
                              "views",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Like button
                                LikeButton(
                                  size: 20,
                                  onTap: (isLiked) async {
                                    ref.read(PostControllerProvider.notifier).likePost(post, currentUser);
                                    return !isLiked;
                                  },
                                  likeBuilder: (isLiked) {
                                    return isLiked
                                        ? SvgPicture.asset(AssetsConstants.upvoteFilled, color: RedColor, height: 18)
                                        : SvgPicture.asset(AssetsConstants.upvoteOutlined, color: Colors.grey, height: 18);
                                  },
                                  isLiked: post.likes.contains(currentUser.uid),
                                  likeCount: post.likes.length,
                                  countBuilder: (likeCount, isLiked, text) {
                                    return Text(
                                      text,
                                      style: TextStyle(
                                        color: isLiked ? RedColor : Colors.grey,
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ),



                                // Retweet/Share button with count


                                // Share button

                              ],
                            ),

                            const SizedBox(width: 15),
                            FutureBuilder(
                              future: ref.read(commentControllerProvider.notifier).fetchReplyCount(post.id),
                              builder: (context, snapshot) {
                                final commentCount = snapshot.data ?? 0;
                                return PostIconButton(
                                  pathName: AssetsConstants.comment,
                                  text: commentCount.toString(),
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                  },
                                );
                              },
                            ),
                            const Spacer(),

                            // Like user avatars
                            if (post.likes.isNotEmpty) ...[
                              SizedBox(
                                width: 50,
                                height: 20,
                                child: Stack(
                                  children: [
                                    for (int i = 0; i < min(3, post.likes.length); i++)
                                      Positioned(
                                        left: i * 15.0,
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            return ref.watch(UserDetailsProvider(post.likes[i])).when(
                                              data: (likerUser) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 8,
                                                    backgroundColor: Colors.grey[300],
                                                    backgroundImage: NetworkImage(
                                                      likerUser.profilePic,
                                                    ),
                                                  ),
                                                );
                                              },
                                              error: (_, __) => Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 8,
                                                  backgroundColor: Colors.grey[300],
                                                  child: const Icon(Icons.person, size: 8, color: Colors.white),
                                                ),
                                              ),
                                              loading: () => Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 8,
                                                  backgroundColor: Colors.grey[300],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            ],
                          ],
                        ),



                        // Action buttons row

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) => ErrorPage(error: error.toString()),
      loading: () => const LoadingPage(),
    );
  }
}

int min(int a, int b) {
  return a < b ? a : b;
}