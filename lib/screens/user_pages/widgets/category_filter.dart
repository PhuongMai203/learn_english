import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const CategoryFilter({
    super.key,
    this.categories = const [
      'Tất cả',
      'Phổ biến',
      'Mới nhất',
      'Đang học',
      'Yêu thích',
    ],
    this.selectedIndex = 0,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (selected) {
                if (selected && onSelected != null) {
                  onSelected!(index);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
