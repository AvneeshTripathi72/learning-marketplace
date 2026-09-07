import 'package:flutter/material.dart';
import '../public_hub/category_browse_screen.dart';

class PublicYoutubeScreen extends StatelessWidget {
  const PublicYoutubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryBrowseScreen(embedInScaffold: false);
  }
}
