import 'package:civicalerts/common/error_page.dart';
import 'package:civicalerts/common/loading_page.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/home/view/home_view.dart';
import 'package:civicalerts/timepass_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Theme/app_theme.dart';
import 'features/WelcomeScreens/main_navigation_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Civic Alerts',
      theme: AppTheme.theme,
      home: ref.watch(currentUserAccountProvider).when(
        data: (user) {
          if (user != null) {
            print("User is logged in: ${user.email}");
            return HomeScreen(); // Navigate to the main screen if user is logged in
          } else {
            print("No user is logged in");
            return const MainNavigationScreen(); // Navigate to the welcome screen if no user is logged in
          }
        },
        error: (error, st) {
          print("Error occurred: $error");
          return ErrorPage(error: error.toString(),
          ); // Show error page if something goes wrong
        },
        loading: () {
          print("Loading...");
          return const LoadingPage(); // Show loading page while fetching user data
        },
      ),
    );
  }
}