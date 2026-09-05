import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../../widgets/video_card.dart';

class PublicationYoutubeScreen extends StatefulWidget {
  const PublicationYoutubeScreen({super.key});

  @override
  State<PublicationYoutubeScreen> createState() => _PublicationYoutubeScreenState();
}

class _PublicationYoutubeScreenState extends State<PublicationYoutubeScreen> {
  String _selectedSeries = 'CBSE 2026';
  String _selectedClass = 'Class 10';
  String _selectedSubject = 'Mathematics';

  final List<VideoModel> _mockVideos = [
    VideoModel(
      id: 'yt_101',
      title: 'Class 10 Math Chapter 1 Real Numbers Full Lecture & Proofs',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Oxford Academic Official',
      category: 'Mathematics',
      thumbnailUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=600&auto=format&fit=crop',
      duration: '42:10',
      viewsCount: 15400,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Pub',
      submittedDate: DateTime.now(),
    ),
    VideoModel(
      id: 'yt_102',
      title: 'Class 10 Math Chapter 2 Polynomials Formulas & Examples',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Oxford Academic Official',
      category: 'Mathematics',
      thumbnailUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop',
      duration: '28:45',
      viewsCount: 9200,
      status: VideoStatus.approved,
      submittedBy: 'Oxford Pub',
      submittedDate: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Publication YouTube Channel'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          HierarchyPicker(
            seriesList: const ['CBSE 2026', 'ICSE 2026', 'State Board'],
            classList: const ['Class 9', 'Class 10', 'Class 11', 'Class 12'],
            subjectList: const ['Mathematics', 'Science', 'English', 'Hindi'],
            selectedSeries: _selectedSeries,
            selectedClass: _selectedClass,
            selectedSubject: _selectedSubject,
            onSeriesChanged: (v) => setState(() => _selectedSeries = v),
            onClassChanged: (v) => setState(() => _selectedClass = v),
            onSubjectChanged: (v) => setState(() => _selectedSubject = v),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _mockVideos.length,
              itemBuilder: (context, index) {
                final video = _mockVideos[index];
                return VideoCard(
                  video: video,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
