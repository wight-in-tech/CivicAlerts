import 'package:civicalerts/Constants/asset_constants.dart';
import 'package:civicalerts/Theme/pallete.dart';
import 'package:civicalerts/enums/notification_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:civicalerts/models/notification_model.dart' as model;

class NotificationTile extends StatelessWidget {
  final model.Notification notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Handle notification tap
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: _buildNotificationIcon(),
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification text
                      Text(
                        notification.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Time and type badge
                      Row(
                        children: [
                          Text(
                            _formatTime(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getTypeText(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    switch (notification.notificationType) {
      case NotificationType.follow:
        return const Icon(
          Icons.person_add_rounded,
          color: Colors.white,
          size: 20,
        );
      case NotificationType.like:
        return SvgPicture.asset(
          AssetsConstants.upvoteFilled,
          color: Colors.white,
          height: 18,
        );
      case NotificationType.complain:
        return const Icon(
          Icons.trending_up_rounded,
          color: Colors.white,
          size: 20,
        );
      case NotificationType.comment:
        return const Icon(
          Icons.comment_rounded,
          color: Colors.white,
          size: 18,
        );

      default:
        return const Icon(
          Icons.notifications_rounded,
          color: Colors.white,
          size: 20,
        );
    }
  }

  Color _getIconBackgroundColor() {
    switch (notification.notificationType) {
      case NotificationType.follow:
        return mainBlue;
      case NotificationType.like:
        return RedColor;
      case NotificationType.complain:
        return Colors.green[600]!;
      case NotificationType.comment:
        return Colors.orange[600]!;
      default:
        return Colors.grey[500]!;
    }
  }

  Color _getTypeColor() {
    switch (notification.notificationType) {
      case NotificationType.follow:
        return mainBlue;
      case NotificationType.like:
        return RedColor;
      case NotificationType.complain:
        return Colors.green[600]!;
      case NotificationType.comment:
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getTypeText() {
    switch (notification.notificationType) {
      case NotificationType.follow:
        return 'FOLLOW';
      case NotificationType.like:
        return 'LIKE';
      case NotificationType.complain:
        return 'CONVERTED';
      case NotificationType.comment:
        return 'COMMENT';
      default:
        return 'NOTIFICATION';
    }
  }

  String _formatTime() {
    // Assuming notification has a timestamp field
    // You can replace this with actual time formatting logic
    return '2m ago'; // Placeholder - implement actual time formatting
  }
}


