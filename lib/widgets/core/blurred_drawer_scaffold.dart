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
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.appBar,
      drawer: widget.drawer,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      onDrawerChanged: (isOpen) {
        if (mounted) {
          setState(() {
            _isDrawerOpen = isOpen;
          });
        }
      },
      drawerScrimColor: Colors.black.withValues(alpha: 0.1), // Lighter scrim since blur is active
      body: _isDrawerOpen
          ? Stack(
              children: [
                widget.body,
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            )
          : widget.body,
    );
  }
}
