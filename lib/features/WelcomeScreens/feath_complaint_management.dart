import 'package:civicalerts/Constants/civicalert_appbar.dart';
import 'package:civicalerts/Theme/pallete.dart';
import 'package:flutter/material.dart';

class FeathComplaintManagement extends StatelessWidget {
  const FeathComplaintManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarConstants.appbar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // App Logo or Illustration with enhanced styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.1),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'images/feature_complaint.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Heading with enhanced styling
                      Text(
                        "Report Issues Seamlessly",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: mainBlue,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Description with enhanced styling
                      Text(
                        "Submit geotagged images and descriptions of issues like potholes or broken streetlights. Your reports create actionable tickets for resolution.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
