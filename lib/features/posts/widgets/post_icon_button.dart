import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PostIconButton extends StatelessWidget {
  final String pathName;
  final String text;
  final VoidCallback onTap;

  const PostIconButton({
    Key? key,
    required this.pathName,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,  // This is key to preventing overflow
        children: [
          SvgPicture.asset(
            pathName,
            color: Colors.grey,
            width: 24,  // Set a fixed width
            height: 24, // Set a fixed height
          ),
          const SizedBox(width: 4),  // Use SizedBox instead of margin
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,  // Slightly smaller font
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}