import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Theme/pallete.dart';

class MyButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLoading;

  const MyButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading
          ? () {} // ✅ Fix: Avoid passing `null`
          : () {
        HapticFeedback.heavyImpact();
        onPressed();
      },
      style: ButtonStyle(
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        backgroundColor: const MaterialStatePropertyAll(mainBlue),
        splashFactory: InkRipple.splashFactory,
      ),
      child: isLoading
          ? LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.white, // ✅ Fix: Ensure loading animation is visible
        size: 35.0,
      )
          : Text(
        buttonText,
        style: GoogleFonts.inter(
          color: Colors.white, // ✅ Fix: Make text always readable
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
