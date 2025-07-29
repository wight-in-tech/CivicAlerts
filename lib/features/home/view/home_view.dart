import 'package:civicalerts/features/explore/view/explore_view.dart';
import 'package:civicalerts/features/notifications/view/notification_view.dart';
import 'package:civicalerts/features/posts/views/create_post.dart';
import 'package:civicalerts/features/posts/widgets/post_list.dart';
import 'package:civicalerts/features/userprofiles/views/user_profile_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Constants/ui_constants.dart';
import '../../../Theme/pallete.dart';
import '../../../core/utils.dart';
import '../../../features/authentication/controller/auth_controller.dart'; // Add this import

class HomeScreen extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => HomeScreen());

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void onPageChange(int index) {
    setState(() {
      _page = index;
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final permissionGranted = await requestLocationPermission(); // This should be your actual permission function
    if (mounted && !permissionGranted) {
      showLocationPermissionSnackBar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _page,
        children: [
          PostList(),
          ExploreView(),
          NotificationView(),
          currentUser != null
              ? UserProfileView(userModel: currentUser)
              : Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, CreatePostScreen.route());
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: CupertinoTabBar(
          currentIndex: _page,
          onTap: onPageChange,
          backgroundColor: backgroundColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _page == 0 ? Icons.other_houses : Icons.other_houses_outlined,
                color: _page == 0 ? mainBlue : Colors.grey,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _page == 1 ? Icons.people_alt : Icons.people_alt_outlined,
                color: _page == 1 ? mainBlue : Colors.grey,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _page == 2 ? Icons.notifications : Icons.notifications_none,
                color: _page == 2 ? mainBlue : Colors.grey,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _page == 3 ? Icons.person : Icons.person_outline,
                color: _page == 3 ? mainBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}