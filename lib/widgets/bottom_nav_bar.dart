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
      {'icon': Icons.quiz_outlined, 'selectedIcon': Icons.quiz, 'label': 'Generators'},
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 6),
          child: SizedBox(
            height: 68,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0x991E1E28),
                              const Color(0x6612121A),
                            ]
                          : [
                              const Color(0xDCFFFFFF),
                              const Color(0xB8F0F4F8),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.85),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.50)
                            : const Color(0x2B1A2438),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      if (!isDark)
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: -2,
                          offset: const Offset(0, -2),
                        ),
                    ],
                  ),
                  child: GestureDetector(
                    onHorizontalDragStart: (details) {
                      final boxWidth = constraints.maxWidth - 32;
                      final itemWidth = boxWidth / navItems.length;
                      final dragIndex = (details.localPosition.dx / itemWidth).clamp(0.0, 4.0).floor();
                      setState(() => _hoveredIndex = dragIndex);
                    },
                    onHorizontalDragUpdate: (details) {
                      final boxWidth = constraints.maxWidth - 32;
                      final itemWidth = boxWidth / navItems.length;
                      final dragIndex = (details.localPosition.dx / itemWidth).clamp(0.0, 4.0).floor();
                      if (_hoveredIndex != dragIndex) {
                        setState(() => _hoveredIndex = dragIndex);
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (_hoveredIndex != null) {
                        final target = _hoveredIndex!;
                        setState(() => _hoveredIndex = null);
                        handleNavigation(target);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(navItems.length, (index) {
                          final item = navItems[index];
                          final isSelected = index == activeIndex;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => handleNavigation(index),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary.withValues(alpha: 0.25),
                                            theme.colorScheme.primary.withValues(alpha: 0.12),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(24),
                                  border: isSelected
                                      ? Border.all(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.45),
                                          width: 1.2,
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
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
                                      size: 21,
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
            ),
          ),
        );
      },
    );
  }
}

/// Helper wrapper that enables full-screen horizontal drag swipe navigation between bottom navbar tabs
class SwipeNavigationWrapper extends ConsumerWidget {
  final int currentIndex;
  final Widget child;

  const SwipeNavigationWrapper({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isPublication = user?.role == UserRole.publication;

    void handleNavigation(int index) {
      if (index == currentIndex || index < 0 || index > 4) return;
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          // Swipe Left -> next tab
          handleNavigation(currentIndex + 1);
        } else if (details.primaryVelocity! > 300) {
          // Swipe Right -> previous tab
          handleNavigation(currentIndex - 1);
        }
      },
      child: child,
    );
  }
}

