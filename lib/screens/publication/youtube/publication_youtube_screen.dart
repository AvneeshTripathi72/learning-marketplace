import 'package:flutter/material.dart';
import '../../../models/video_model.dart';
import '../../../widgets/hierarchy_picker.dart';
import '../../../widgets/video_card.dart';
import '../../shared/video_player/video_player_screen.dart';

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
      title: 'Class 10 Math Chapter 1 Real Numbers Full Lecture',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      platform: VideoPlatform.youtube,
      channelName: 'Oxford Academic YouTube',
      category: 'Mathematics',
      thumbnailUrl: 'https://via.placeholder.com/300x180',
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
      channelName: 'Oxford Academic YouTube',
      category: 'Mathematics',
      thumbnailUrl: 'https://via.placeholder.com/300x180',
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
      appBar: AppBar(
        title: const Text('Publication YouTube Channel'),
      ),
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: VideoCard(
                    video: video,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(video: video),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
