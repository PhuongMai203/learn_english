import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color darkBlue;

  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.primaryColor,
    required this.darkBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [primaryColor, darkBlue]),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Tạo bài tập',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
