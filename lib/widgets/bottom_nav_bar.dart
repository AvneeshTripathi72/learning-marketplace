import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPublication = user?.role == UserRole.publication;

    final navItems = [
      {'icon': Icons.home_outlined, 'selectedIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.menu_book_outlined, 'selectedIcon': Icons.menu_book, 'label': 'eBooks'},
      {'icon': Icons.bolt_outlined, 'selectedIcon': Icons.bolt, 'label': 'Shorts'},
      {'icon': Icons.quiz_outlined, 'selectedIcon': Icons.quiz, 'label': 'Generators'},
      {'icon': Icons.bookmark_border_outlined, 'selectedIcon': Icons.bookmark, 'label': 'My Library'},
    ];

    void handleNavigation(int index) {
      if (index == currentIndex) return;
      switch (index) {
        case 0:
          context.go(isPublication ? '/dashboard' : '/public/dashboard');
          break;
        case 1:
          context.push(isPublication ? '/pub/ebook' : '/public/ebook');
          break;
        case 2:
          context.push(isPublication ? '/pub/youtube' : '/public/youtube');
          break;
        case 3:
          context.push(
            isPublication ? '/pub/question-paper' : '/public/question-paper',
          );
          break;
        case 4:
          context.push('/profile');
          break;
      }
    }

    return SizedBox(
      height: 70,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xDD1E1E1E)
                    : const Color(0xEEF5F5F7),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => handleNavigation(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? (item['selectedIcon'] as IconData)
                                  : (item['icon'] as IconData),
                              size: 20,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['label'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
