import 'package:flutter/material.dart';

class CategoryChipWidget extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryChipWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryChipWidget> createState() => _CategoryChipWidgetState();
}

class _CategoryChipWidgetState extends State<CategoryChipWidget> {
  final List<String> categoryList = ["SUV", "MPV", "LCGC", "Sports"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 8.0,
        children: categoryList.map((category) {
          return ChoiceChip(
            backgroundColor: Colors.white,
            label: Text(category),
            selected: widget.selectedCategory == category,
            onSelected: (isSelected) {
              widget.onCategorySelected(isSelected ? category : "");
            },
            selectedColor: const Color.fromARGB(255, 0, 28, 53),
            labelStyle: TextStyle(
              color: widget.selectedCategory == category
                  ? Colors.white
                  : Colors.black,
            ),
          );
        }).toList(),
      ),
    );
  }
}
