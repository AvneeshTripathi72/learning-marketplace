import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredDrawerScaffold extends StatefulWidget {
  final Widget? drawer;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const BlurredDrawerScaffold({
    super.key,
    this.drawer,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  State<BlurredDrawerScaffold> createState() => _BlurredDrawerScaffoldState();
}

class _BlurredDrawerScaffoldState extends State<BlurredDrawerScaffold> {
  bool _isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blurOverlayColor = isDark
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.35);

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.appBar,
      drawer: widget.drawer,
      bottomNavigationBar: _isDrawerOpen ? null : widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      onDrawerChanged: (isOpen) {
        if (mounted) {
          setState(() {
            _isDrawerOpen = isOpen;
          });
        }
      },
      drawerScrimColor: Colors.transparent,
      body: Stack(
        children: [
          widget.body,
          if (_isDrawerOpen)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  color: blurOverlayColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
