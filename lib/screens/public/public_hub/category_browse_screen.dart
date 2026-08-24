import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/category_provider.dart';
import '../../../widgets/category_chip_list.dart';

class CategoryBrowseScreen extends ConsumerStatefulWidget {
  const CategoryBrowseScreen({super.key});

  @override
  ConsumerState<CategoryBrowseScreen> createState() => _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends ConsumerState<CategoryBrowseScreen> {
  String _selectedCategoryId = 'cat_1';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(enabledCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Video Hub'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No active public categories available.'));
          }

          return Column(
            children: [
              const SizedBox(height: 8),
              CategoryChipList(
                categories: categories,
                selectedCategoryId: _selectedCategoryId,
                onSelected: (id) => setState(() => _selectedCategoryId = id),
              ),
              const Divider(height: 24),
              const Expanded(
                child: Center(
                  child: Text('Displaying videos for selected category.'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading public categories')),
      ),
    );
  }
}
