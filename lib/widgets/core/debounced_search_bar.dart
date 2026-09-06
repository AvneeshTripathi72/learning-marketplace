import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class DebouncedSearchBar extends StatefulWidget {
  final String hintText;
  final void Function(String) onChanged;
  final Duration debounceDuration;

  const DebouncedSearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged(query);
    });
    setState(() {}); // For showing/hiding clear icon
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      style: AppTypography.body(theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTypography.body(theme.colorScheme.onSurface.withOpacity(0.5)),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                onPressed: () {
                  _controller.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
