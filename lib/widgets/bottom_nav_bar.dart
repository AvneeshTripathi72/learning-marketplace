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

    final accentColor = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF161618).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Glowing Top Active Line Indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                height: 3.5,
                                width: isSelected ? 28 : 0,
                                decoration: BoxDecoration(
                                  color: isSelected ? accentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: accentColor.withValues(alpha: 0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : [],
                                ),
                              ),

                              // Content Pill Container
                              Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accentColor.withValues(alpha: isDark ? 0.18 : 0.12)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedScale(
                                        scale: isSelected ? 1.15 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          isSelected
                                              ? (item['selectedIcon'] as IconData)
                                              : (item['icon'] as IconData),
                                          size: 21,
                                          color: isSelected
                                              ? accentColor
                                              : (isDark ? Colors.white60 : Colors.black54),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          item['label'] as String,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            fontSize: 10.5,
                                            color: isSelected
                                                ? accentColor
                                                : (isDark ? Colors.white60 : Colors.black54),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Bottom Balancing Spacer
                              const SizedBox(height: 3),
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
