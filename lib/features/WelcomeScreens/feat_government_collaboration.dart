import 'package:civicalerts/Constants/civicalert_appbar.dart';
import 'package:civicalerts/Theme/pallete.dart';
import 'package:flutter/material.dart';

class FeatGovernmentCollaboration extends StatelessWidget {
  const FeatGovernmentCollaboration({super.key});

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
                      // Image with shadow and border radius
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white,
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
                            'images/collab.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Heading with solid color
                      const Text(
                        "Collaborate for Change",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: mainBlue, // Assuming `mainBlue` is defined in ui_constants.dart
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Feature highlights with icons
                      Column(
                        children: [
                          _buildFeatureItem(
                            Icons.handshake_outlined,
                            "Partnerships with Authorities",
                            "We work with local governments to address reported issues effectively.",
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureItem(
                            Icons.people_outline,
                            "Community-Driven Change",
                            "Empower your community to identify and resolve pressing concerns.",
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureItem(
                            Icons.construction_outlined,
                            "Action-Oriented Approach",
                            "Every report leads to actionable steps and progress updates.",
                          ),
                        ],
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

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
