import 'package:civicalerts/features/posts/widgets/comment_button.dart';
import 'package:civicalerts/features/userprofiles/views/user_profile_view.dart';
import 'package:logger/logger.dart';
import 'package:civicalerts/Constants/asset_constants.dart';
import 'package:civicalerts/Theme/pallete.dart';
import 'package:civicalerts/common/error_page.dart';
import 'package:civicalerts/common/loading_page.dart';
import 'package:civicalerts/core/utils.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/posts/controller/comment_controller.dart';
import 'package:civicalerts/features/posts/controller/post_controller.dart';
import 'package:civicalerts/features/posts/widgets/carousel_image.dart';
import 'package:civicalerts/features/posts/widgets/post_icon_button.dart';
import 'package:civicalerts/models/comment_model.dart';
import 'package:civicalerts/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:badges/badges.dart' as badges;

class PostReplyViewCard extends ConsumerStatefulWidget {
  static route(Post post) => MaterialPageRoute(
      builder: (context) => PostReplyViewCard(
        post: post,
      ));
  final Post post;
  const PostReplyViewCard({
    super.key,
    required this.post,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostReplyViewCardState();
}

class _PostReplyViewCardState extends ConsumerState<PostReplyViewCard> {
  final Logger logger = Logger();
  bool isUpvoted = false;
  final commentController = TextEditingController();
  int upvoteCount = 0;

  LatLng getGoogleMapLocation() {
    final googleMapLocation = stringToLatLng(widget.post.location);
    return googleMapLocation;
  }

  @override
  void initState() {
    super.initState();
    upvoteCount = widget.post.likes.length;
  }

  void onComment() {
    ref.watch(commentControllerProvider.notifier).uploadComment(
      commentText: commentController.text,
      context: context,
      repliedTo: widget.post.id,
    );
    commentController.clear();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(commentControllerProvider);

    return currentUser == null
        ? const Loader()
        : ref.watch(UserDetailsProvider(widget.post.uid)).when(
      data: (user) {
        final createdAtDateTime = DateTime.fromMillisecondsSinceEpoch(widget.post.createdAt);
        return GestureDetector(
          onTap: () {Navigator.push(context,UserProfileView.route(user), );},
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile header
                _buildUserHeader(user, createdAtDateTime),

                // Post content
                _buildPostContent(),

                // Location map
                if (widget.post.location != 'Location not available')
                  _buildLocationMap(),

                // Image carousel
                if (widget.post.imageLinks.isNotEmpty)
                  _buildImageCarousel(),

                // Interaction buttons
                _buildInteractionButtons(currentUser, isLoading),

                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color.fromARGB(70, 157, 179, 241),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => ErrorText(
        error: error.toString(),
      ),
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: LoadingPage()),
      ),
    );
  }

  Widget _buildUserHeader(user, DateTime createdAtDateTime) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture with verified badge if applicable
          user.isVerified
              ? _buildVerifiedAvatar(user)
              : CircleAvatar(
            backgroundImage: NetworkImage(user.profilePic),
            radius: 24,
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(createdAtDateTime, locale: 'en_short'),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 102, 101, 101),
                    fontSize: 13,
                    fontFamily: 'Mulish',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedAvatar(user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                mainBlue.withOpacity(0.7),
                Colors.red.withOpacity(0.9),
                softBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        badges.Badge(
          badgeContent: const Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          ),
          badgeStyle: const badges.BadgeStyle(
            shape: badges.BadgeShape.twitter,
            badgeColor: softBlue,
            padding: EdgeInsets.all(6),
          ),
          position: badges.BadgePosition.topEnd(top: -6, end: -3),
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.profilePic),
            radius: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post title
          Text(
            widget.post.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Mulish',
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),

          // Post description
          Text(
            widget.post.description,
            style: const TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Location text
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: softBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.post.location,
                  style: const TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLocationMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: getGoogleMapLocation(),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('complaint_location'),
                    position: getGoogleMapLocation(),
                  ),
                },
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Images',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
           // height: 240,
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: ClipRRect(
             // borderRadius: BorderRadius.circular(12),
              child: CarouselImage(imageLinks: widget.post.imageLinks),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInteractionButtons(currentUser, isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Upvote button
          Row(
            children: [
              LikeButton(
                size: 26,
                isLiked: widget.post.likes.contains(currentUser.uid),
                onTap: (isLiked) async {
                  setState(() {
                    isUpvoted = !isLiked;
                    if (isUpvoted) {
                      upvoteCount++;
                    } else {
                      upvoteCount--;
                    }
                    HapticFeedback.mediumImpact();
                  });
                  return isUpvoted;
                },
                likeCountAnimationDuration: const Duration(milliseconds: 100),
                likeBuilder: (isLiked) {
                  return isLiked
                      ? SvgPicture.asset(
                    AssetsConstants.upvoteFilled,
                    colorFilter: const ColorFilter.mode(
                      scaffoldMessengerColor,
                      BlendMode.srcIn,
                    ),
                  )
                      : SvgPicture.asset(
                    AssetsConstants.upvoteOutlined,
                    height: 25,
                    colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 146, 144, 144),
                      BlendMode.srcIn,
                    ),
                  );
                },
                likeCount: upvoteCount,
                countBuilder: (likeCount, isLiked, text) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isLiked
                            ? mainBlue
                            : const Color.fromARGB(255, 117, 116, 116),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Views counter
          FutureBuilder(
            future: ref.read(commentControllerProvider.notifier).fetchReplyCount(widget.post.id),
            builder: (context, snapshot) {
              final commentCount = snapshot.data ?? 0;
              return PostIconButton(
                pathName: AssetsConstants.views,
                text: (commentCount + upvoteCount).toString(),
                onTap: () {},
              );
            },
          ),

          // Comment button
          FutureBuilder(
            future: ref.read(commentControllerProvider.notifier).fetchReplyCount(widget.post.id),
            builder: (context, snapshot) {
              final commentCount = snapshot.data ?? 0;
              return PostIconButton(
                pathName: AssetsConstants.comment,
                text: commentCount.toString(),
                onTap: () {
                  setState(() {
                    HapticFeedback.mediumImpact();
                  });
                  _showCommentBottomSheet(isLoading);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCommentBottomSheet(bool isLoading) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ref.watch(UserDetailsProvider(widget.post.uid)).when(
          data: (user) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                height: 280,
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.profilePic),
                            radius: 16,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add a comment to ${user.name}\'s post',
                              style: const TextStyle(
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: commentController,
                        maxLength: 150,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (value) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            setState(() {});
                          });
                        },
                        onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: 'Write your comment here...',
                          hintStyle: const TextStyle(
                            fontFamily: 'Gilroy',
                            color: Color(0xFF9E9E9E),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: mainBlue),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          counterText: '${commentController.text.length}/150',
                          counterStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: CommentButton(
                              buttonText: 'Post',
                              isLoading: isLoading,
                              onPressed: () {
                                onComment();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}