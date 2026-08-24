import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChipList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  const CategoryChipList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat.name),
              selected: isSelected,
              onSelected: (_) => onSelected(cat.id),
            ),
          );
        },
      ),
    );
  }
}
