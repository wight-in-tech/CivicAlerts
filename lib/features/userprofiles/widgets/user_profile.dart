import 'package:civicalerts/Theme/pallete.dart';
import 'package:civicalerts/common/error_page.dart';
import 'package:civicalerts/common/loading_page.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/posts/widgets/post_card.dart';
import 'package:civicalerts/features/userprofiles/controller/user_profile_controller.dart';
import 'package:civicalerts/features/userprofiles/views/edit_profile_view.dart';
import 'package:civicalerts/features/userprofiles/widgets/follow_count.dart';
import 'package:civicalerts/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Constants/asset_constants.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader()
        : NestedScrollView(

      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            flexibleSpace: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(

                      backgroundImage: NetworkImage(user.profilePic),
                      radius: 45,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  margin: const EdgeInsets.all(20),
                  child: OutlinedButton(
                    onPressed: () {
                      if (currentUser.uid == user.uid) {
                        // edit profile
                        Navigator.push(context, EditProfileView.route());
                      } else {
                        ref
                            .read(userProfileControllerProvider.notifier)
                            .followUser(
                          user: user,
                          context: context,
                          currentUser: currentUser,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: mainBlue,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                    ),
                    child: Text(
                      currentUser.uid == user.uid
                          ? 'Edit Profile'
                          : currentUser.following.contains(user.uid)
                          ? 'Unfollow'
                          : 'Follow',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '@${user.name}',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FollowCount(
                        count: user.following.length,
                        text: 'Following',
                      ),
                      const SizedBox(width: 15),
                      FollowCount(
                        count: user.followers.length,
                        text: 'Followers',
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Divider(color: Colors.white),
                ],
              ),
            ),
          ),
        ];
      },
      body: ref.watch(getUserPostsProvider(user.uid)).when(
        data: (posts) {
          // can make it realtime by copying code
          // from twitter_reply_view
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) {
              final post= posts[index];
              return PostCard(post: post);
            },
          );
        },
        error: (error, st) => ErrorText(
          error: error.toString(),
        ),
        loading: () => const Loader(),
      ),
    );
  }
}