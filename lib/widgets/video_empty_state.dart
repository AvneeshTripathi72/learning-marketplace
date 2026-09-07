import 'package:flutter/material.dart';

enum EmptyStateType {
  noSearchResults,
  noCategoryVideos,
  networkError,
  permissionDenied,
  offline,
}

class VideoEmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? customMessage;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const VideoEmptyState({
    super.key,
    this.type = EmptyStateType.noSearchResults,
    this.customMessage,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final IconData iconData;
    final Color iconColor;
    final String title;
    final String subtitle;
    final String defaultButtonText;

    switch (type) {
      case EmptyStateType.noSearchResults:
        iconData = Icons.search_off_rounded;
        iconColor = const Color(0xFF7C9CFF);
        title = 'No Video Lectures Found';
        subtitle = customMessage ?? 'We couldn\'t find any videos matching your search criteria or filters.';
        defaultButtonText = 'Clear Filters & View All';
        break;

      case EmptyStateType.noCategoryVideos:
        iconData = Icons.video_library_outlined;
        iconColor = Colors.orangeAccent;
        title = 'No Videos in This Subject';
        subtitle = customMessage ?? 'There are currently no approved video lectures uploaded in this category.';
        defaultButtonText = 'Browse All Subjects';
        break;

      case EmptyStateType.networkError:
        iconData = Icons.wifi_off_rounded;
        iconColor = const Color(0xFFFF6B6B);
        title = 'Connection Error';
        subtitle = customMessage ?? 'Failed to connect to the educational video server. Please check your internet connection.';
        defaultButtonText = 'Try Again';
        break;

      case EmptyStateType.permissionDenied:
        iconData = Icons.lock_outline_rounded;
        iconColor = Colors.amber;
        title = 'Access Restricted';
        subtitle = customMessage ?? 'You need proper student or publisher authorization to view this video collection.';
        defaultButtonText = 'Sign In to Access';
        break;

      case EmptyStateType.offline:
        iconData = Icons.cloud_off_rounded;
        iconColor = Colors.tealAccent;
        title = 'You\'re Offline';
        subtitle = customMessage ?? 'You are in offline mode. Only downloaded video notes & bookmarks are accessible.';
        defaultButtonText = 'Go to Downloads';
        break;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing Animated Background Circle
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                iconData,
                size: 54,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            if (onActionPressed != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                onPressed: onActionPressed,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  actionLabel ?? defaultButtonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
