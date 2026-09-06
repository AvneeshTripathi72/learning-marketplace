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

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1E1E1E).withValues(alpha: 0.92) 
                : Colors.white.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = index == activeIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => handleNavigation(index),
                        behavior: HitTestBehavior.opaque,
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _hoveredIndex = index),
                          onExit: (_) => setState(() => _hoveredIndex = null),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? const Color(0xFF7C9CFF).withValues(alpha: 0.2)
                                        : const Color(0xFF4A6CF7).withValues(alpha: 0.12))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isSelected
                                        ? (item['selectedIcon'] as IconData)
                                        : (item['icon'] as IconData),
                                    size: 22,
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7))
                                        : (isDark ? Colors.white70 : Colors.black54),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item['label'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 11,
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7))
                                          : (isDark ? Colors.white70 : Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
