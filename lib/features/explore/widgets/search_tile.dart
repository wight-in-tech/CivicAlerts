// import 'package:civicalerts/models/user_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// class SearchTile extends StatelessWidget {
//   final UserModel userModel;
//   const SearchTile({
//     super.key,
//     required this.userModel,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () {
//         // Navigator.push(
//         //  // context,
//         //
//         //   //UserProfileView.route(userModel),
//         // );
//       },
//       leading: CircleAvatar(
//         backgroundImage: NetworkImage(userModel.profilePic),
//         radius: 30,
//       ),
//       title: Text(
//         userModel.name,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '@${userModel.name}',
//             style: const TextStyle(
//               fontSize: 16,
//             ),
//           ),
//           Text(
//             userModel.uid,
//             style: const TextStyle(
//               color: CupertinoColors.secondarySystemBackground,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:civicalerts/features/userprofiles/views/user_profile_view.dart';
import 'package:civicalerts/models/user_model.dart';
import 'package:civicalerts/timepass_screen.dart';
import 'package:flutter/material.dart';

class EnhancedSearchTile extends StatefulWidget {
  final UserModel userModel;
  final int index;

  const EnhancedSearchTile({
    super.key,
    required this.userModel,
    this.index = 0,
  });

  @override
  State<EnhancedSearchTile> createState() => _EnhancedSearchTileState();
}

class _EnhancedSearchTileState extends State<EnhancedSearchTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileView(userModel: widget.userModel),
                  ),
                );
              },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Enhanced Avatar
                      _buildAvatar(),
                      const SizedBox(width: 16),

                      // User Info
                      Expanded(
                        child: _buildUserInfo(),
                      ),

                      // Action Button
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: widget.userModel.profilePic.isNotEmpty
              ? Image.network(
            widget.userModel.profilePic,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildAvatarFallback();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 56,
                height: 56,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            },
          )
              : _buildAvatarFallback(),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.userModel.name.isNotEmpty
              ? widget.userModel.name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name
        Text(
          widget.userModel.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Username
        Text(
          '@${widget.userModel.name.toLowerCase().replaceAll(' ', '')}',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        // User ID chip

      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   UserProfileView.route(UserModel as UserModel),
          // );
          Navigator.push(context, TimepassScreen() as Route<Object?>);
        },
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Theme.of(context).primaryColor,
          size: 18,
        ),
        tooltip: 'View Profile',
      ),
    );
  }
}

// Alternative simpler version if you prefer
class SearchTile extends StatelessWidget {
  final UserModel userModel;

  const SearchTile({
    super.key,
    required this.userModel,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          // Navigation logic
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userModel.profilePic),
          radius: 24,
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          userModel.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${userModel.name.toLowerCase().replaceAll(' ', '')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  userModel.uid.substring(0, 8),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}