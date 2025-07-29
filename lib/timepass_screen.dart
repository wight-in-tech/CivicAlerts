import 'package:civicalerts/Constants/civicalert_appbar.dart';
import 'package:flutter/material.dart';

class TimepassScreen extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => TimepassScreen());
  const TimepassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarConstants.appbar(),
      backgroundColor: Colors.black, // Setting the background color to black
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40), // Adding space at the top
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "images/angry_guy.jpeg",
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Haan Bhai project banane mein bohot maja aata hai",
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
