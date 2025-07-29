import 'package:civicalerts/Theme/pallete.dart';
import 'package:civicalerts/features/WelcomeScreens/introduction_screen.dart';
import 'package:civicalerts/features/authentication/view/login_view.dart';

import 'feat_government_collaboration.dart';
import 'feat_realtime_updates.dart';
import 'feath_complaint_management.dart';
import 'onboarding_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    IntroductionScreen(),
    FeathComplaintManagement(),
    FeatRealtimeUpdates(),
    FeatGovernmentCollaboration(),
    OnboardingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if (_currentIndex < _pages.length - 1) {
            setState(() {
              _currentIndex++;
            });
          } else {
           // Navigate to the Sign-Up screen when "Get Started" is tapped
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                   builder: (context) => LoginScreen()
                )
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: 60,
          color: mainBlue, // The main blue color for the entire bottom bar
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentIndex < _pages.length - 1 ? "Next" : "Get started",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _currentIndex < _pages.length - 1
                    ? Icons.arrow_forward_rounded
                    : Icons.check_circle_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}