import 'package:civicalerts/Constants/civicalert_appbar.dart';
import 'package:civicalerts/Theme/pallete.dart';
import 'package:flutter/material.dart';

class FeatRealtimeUpdates extends StatelessWidget {
  const FeatRealtimeUpdates({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppbarConstants.appbar(),
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
                   //   const SizedBox(height: 32),
                      // Image with enhanced container
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              mainBlue.withOpacity(0.1),
                              Colors.white,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: mainBlue.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'images/realtimeupdates.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Heading with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 32,
                            color: mainBlue,
                          ),
                      //    const SizedBox(width: 12),
                          const Flexible(
                            child: Text(
                              "Track Complaints in Real-Time",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Feature points with icons
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              Icons.notifications_active_outlined,
                              "Live Updates",
                              "Stay informed with instant progress notifications",
                            ),
                            const SizedBox(height: 20),
                            _buildFeatureItem(
                              Icons.people_outline,
                              "Community Engagement",
                              "Connect with others to prioritize local issues",
                            ),
                            const SizedBox(height: 20),
                            _buildFeatureItem(
                              Icons.track_changes_outlined,
                              "Progress Tracking",
                              "Monitor your complaint's journey to resolution",
                            ),
                          ],
                        ),
                      ),
                     // const SizedBox(height: 32),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: mainBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: mainBlue,
            size: 24,
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
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
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