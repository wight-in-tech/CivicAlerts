import 'dart:io';
import 'package:civicalerts/common/loading_page.dart';
import 'package:civicalerts/core/utils.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/userprofiles/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
    builder: (context) => const EditProfileView(),
  );
  const EditProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late TextEditingController nameController;


  File? profileFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: ref.read(currentUserDetailsProvider).value?.name ?? '',
    );

  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }



  void selectProfileImage() async {
    final profileImage = await pickImage();
    if (profileImage != null) {
      setState(() {
        profileFile = profileImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(userProfileControllerProvider.notifier)
                  .updateUserProfile(
                userModel: user!.copyWith(

                  name: nameController.text,
                ),
                context: context,

                profileFile: profileFile,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: isLoading || user == null
          ? const Loader()
          : Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [

                Positioned(
                  bottom: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: selectProfileImage,
                    child: profileFile != null
                        ? CircleAvatar(
                      backgroundImage: FileImage(profileFile!),
                      radius: 40,
                    )
                        : CircleAvatar(
                      backgroundImage:
                      NetworkImage(user.profilePic),
                      radius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Name',
              contentPadding: EdgeInsets.all(18),
            ),
          ),
          const SizedBox(height: 20),

        ],
      ),
    );
  }
}