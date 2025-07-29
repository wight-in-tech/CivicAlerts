import 'package:civicalerts/Constants/asset_constants.dart';
import 'package:civicalerts/Theme/pallete.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;


class CommentCard extends ConsumerWidget {
  final CommentModel comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentedUser = ref.watch(UserDetailsProvider(comment.uid)).value;
    return Card(
      shadowColor: Colors.transparent,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: commentedUser?.profilePic != null
                      ? NetworkImage(commentedUser!.profilePic)
                      : const AssetImage(AssetsConstants.profilePic)
                  as ImageProvider,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: Text(
                            commentedUser?.name ?? "Unknown User",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Mulish',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: Text(
                            timeago.format(
                              comment.commentedAt,
                              locale: 'en_full',
                              allowFromNow: true,
                            ),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 102, 101, 101),
                              fontSize: 12,
                              fontFamily: 'Mulish',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            comment.commentText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Gilroy',
                              fontSize: 17,
                            ),
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // Text(
                        //   'Commented by: ${comment.uid}',
                        //   style: Theme.of(context).textTheme.bodySmall,
                        // ),
                        // Text(
                        //   'At: ${comment.commentedAt.toString()}',
                        //   style: Theme.of(context).textTheme.bodySmall,
                        // ),

                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: const Divider(
                indent: 0,
                height: 0,
                thickness: 0.5,
                color: Color.fromARGB(70, 157, 179, 241),
              ),
            ),
          ],
        ),
      ),
    );
  }
}