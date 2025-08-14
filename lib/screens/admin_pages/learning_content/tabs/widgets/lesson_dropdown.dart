import 'package:flutter/material.dart';

class LessonDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> lessons;
  final String? selectedLessonId;
  final ValueChanged<String?> onChanged;
  final Color primaryColor;

  const LessonDropdown({
    super.key,
    required this.lessons,
    required this.selectedLessonId,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chọn bài học', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedLessonId,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: primaryColor),
          items: lessons
              .map((lesson) => DropdownMenuItem<String>(
            value: lesson['id'],
            child: Text(lesson['name'], overflow: TextOverflow.ellipsis),
          ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.menu_book, color: primaryColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
