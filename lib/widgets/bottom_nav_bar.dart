import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class CustomBottomNavBar extends ConsumerStatefulWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  ConsumerState<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends ConsumerState<CustomBottomNavBar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPublication = user?.role == UserRole.publication;

    final navItems = [
      {'icon': Icons.home_outlined, 'selectedIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.menu_book_outlined, 'selectedIcon': Icons.menu_book, 'label': 'eBooks'},
      {'icon': Icons.play_circle_outline, 'selectedIcon': Icons.play_circle, 'label': 'Videos'},
      {'icon': Icons.quiz_outlined, 'selectedIcon': Icons.quiz, 'label': 'Test Gen'},
      {'icon': Icons.person_outlined, 'selectedIcon': Icons.person, 'label': 'Profile'},
    ];

    final activeIndex = _hoveredIndex ?? widget.currentIndex;

    void handleNavigation(int index) {
      if (index < 0 || index >= navItems.length) return;
      if (index == widget.currentIndex) return;
      switch (index) {
        case 0:
          context.go(isPublication ? '/dashboard' : '/public/dashboard');
          break;
        case 1:
          context.go(isPublication ? '/pub/ebook' : '/public/ebook');
          break;
        case 2:
          context.go(isPublication ? '/pub/youtube' : '/public/youtube');
          break;
        case 3:
          context.go(isPublication ? '/pub/question-paper' : '/public/question-paper');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.black.withValues(alpha: 0.6) 
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.1) 
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = index == activeIndex;

                    return GestureDetector(
                      onTap: () => handleNavigation(index),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hoveredIndex = index),
                        onExit: (_) => setState(() => _hoveredIndex = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 20 : 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? (item['selectedIcon'] as IconData)
                                    : (item['icon'] as IconData),
                                size: 24,
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? Colors.white70 : Colors.black54),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          item['label'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: isDark ? Colors.black : Colors.white,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
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
      ),
    );
  }
}
