import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle inputText = TextStyle(
    color: Color(0xFF1D3557),
    fontSize: 16,
  );

  static const TextStyle inputLabel = TextStyle(
    color: Color(0xFF457B9D),
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const TextStyle inputHint = TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: inputLabel,
      hintText: hint,
      hintStyle: inputHint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9), // nổi bật trên nền gradient
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF457B9D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1D3557), width: 2),
      ),
    );
  }
}
