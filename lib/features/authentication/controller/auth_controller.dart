import 'package:appwrite/models.dart';
import 'package:civicalerts/apis/auth_api.dart';
import 'package:civicalerts/core/utils.dart';
import 'package:civicalerts/features/WelcomeScreens/main_navigation_screen.dart';
import 'package:civicalerts/features/authentication/view/signup_view.dart';
import 'package:civicalerts/features/home/view/home_view.dart';
import 'package:civicalerts/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/user_api.dart';

/// **AuthController Provider**
final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
      authapi: ref.watch(authApiProvider), userapi: ref.watch(userApiProvider));
});

final currentUserDetailsProvider = FutureProvider((ref) {
  final currentUserId = ref.watch(currentUserAccountProvider).value!.$id;
  final userDetails = ref.watch(UserDetailsProvider(currentUserId));
  return userDetails.value;
});

final UserDetailsProvider = FutureProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

/// **Current User Provider**
final currentUserAccountProvider = FutureProvider<User?>((ref) async {
  final authController = ref.read(authControllerProvider.notifier);
  return authController.currentUser();
});

/// **AuthController Class**
class AuthController extends StateNotifier<bool> {
  final AuthApi _authApi;
  final UserApi _userApi;
  AuthController({required AuthApi authapi, required UserApi userapi})
      : _authApi = authapi,
        _userApi = userapi,
        super(false);

  /// **Fetch the Current User**
  Future<User?> currentUser() async {
    try {
      return await _authApi.CurrentUserAccount();
    } catch (e) {
      print("Error fetching current user: $e");
      return null;
    }
  }

  /// **Sign Up a New User**
  Future<void> SignUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true; // Start loading
    final res = await _authApi.signUp(email: email, password: password);

    res.fold(
      (l) => ShowSnakBar(context, l.message), // Show error message
      (r) async {
        // Create a UserModel object
        UserModel userModel = UserModel(
          email: email,
          name: GetnamefromEmail(email),
          address: '',
          uid: r.$id, // Use the user ID returned from Appwrite
          profilePic: '',
          mobileNo: '',
          isVerified: false, followers: [], following: [],
        );

        // Save the user data to the database
        final saveResult = await _userApi.saveUserData(userModel);
        saveResult.fold(
          (l) => ShowSnakBar(context, l.message), // Show error message
          (r) {
            ShowSnakBar(context, "Account Created, Please Login to continue");
            Navigator.pop(context); // Navigate back after successful sign-up
          },
        );
      },
    );
    state = false; // Stop loading
  }

  /// **Login an Existing User**
  Future<void> Login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true; // Start loading
    final res = await _authApi.login(email: email, password: password);
    res.fold(
      (l) => ShowSnakBar(context, l.message), // Show error message
      (r) {
        Navigator.push(context, HomeScreen.route()); // Navigate to main screen
      },
    );
    state = false; // Stop loading
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userApi.getUserData(uid);
    final UpdatedUser = UserModel.fromMap(document.data);
    return UpdatedUser;
  }

  void logout(BuildContext context) async {
    final res = await _authApi.logout();

    res.fold(
          (l) => ShowSnakBar(context, l.message),   // surface any error
          (_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignupScreen()),
              (route) => false,                      // clear the whole stack
        );
      },
    );
  }

}
