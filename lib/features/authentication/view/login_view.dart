import 'package:civicalerts/Theme/pallete.dart';
import 'package:civicalerts/features/authentication/controller/auth_controller.dart';
import 'package:civicalerts/features/authentication/view/signup_view.dart';
import 'package:civicalerts/features/authentication/widgets/auth_field.dart';
import 'package:civicalerts/features/authentication/widgets/mybutton.dart';
import 'package:civicalerts/timepass_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constants/civicalert_appbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => LoginScreen());
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void OnLogin(){
    final res = ref.read(authControllerProvider.notifier).Login(email: emailController.text, password: passwordController.text, context: context);
 //
 // Navigator.push(context, TimepassScreen.route());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarConstants.appbar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Welcome back to CivicAlerts",
                  style: GoogleFonts.inter(
                    color: mainBlue,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Raising Awareness,\nBridging Communities',
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                AuthField(controller: emailController, hintText: "Enter Email"),
                const SizedBox(height: 15),
                AuthField(controller: passwordController, hintText: "Enter Password"),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MyButton(
                    buttonText: "Log In",
                    onPressed: () {OnLogin();},
                    isLoading: false,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: GoogleFonts.inter(
                            color: mainBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                  SignupScreen.route(),

                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
