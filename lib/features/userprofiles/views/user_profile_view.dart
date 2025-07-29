import 'package:civicalerts/Constants/appwriteconstants.dart';
import 'package:civicalerts/common/error_page.dart';
import 'package:civicalerts/features/userprofiles/controller/user_profile_controller.dart';
import 'package:civicalerts/features/userprofiles/widgets/user_profile.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/userprofiles/widgets/side_drawer.dart';
import 'package:civicalerts/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileView extends ConsumerWidget {
  static route(UserModel userModel) => MaterialPageRoute(
    builder: (context) => UserProfileView(
      userModel: userModel,
    ),
  );

  final UserModel userModel;

  const UserProfileView({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = userModel;
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    // Check if current user is viewing their own profile
    final bool isOwnProfile = currentUser?.uid == userModel.uid;

    return Scaffold(
      // Show endDrawer only if user is viewing their own profile
      endDrawer: isOwnProfile ? const SideDrawer() : null,
      body: ref.watch(getLatestUserProfileDataProvider).when(
        data: (data) {
          // Check if the realtime data contains updates for this user
          if (data.events.contains(
            'databases.*.collections.${AppwriteConstants.usersCollection}.documents.${copyOfUser.uid}.update',
          )) {
            copyOfUser = UserModel.fromMap(data.payload);
          }
          return UserProfile(user: copyOfUser);
        },
        error: (error, st) => ErrorText(
          error: error.toString(),
        ),
        loading: () {
          return UserProfile(user: copyOfUser);
        },
      ),
    );
  }
}