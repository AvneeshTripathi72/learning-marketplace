import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/ebook_model.dart';

class DownloadManagerService {
  final Dio _dio = Dio();

  Future<String?> downloadEBook(EBookModel ebook, String saveDir) async {
    try {
      final filePath = '$saveDir/${ebook.id}.pdf';
      await _dio.download(ebook.fileUrl, filePath);

      ebook.isDownloaded = true;
      ebook.localPath = filePath;

      final box = Hive.box('offline_ebooks');
      await box.put(ebook.id, filePath);

      return filePath;
    } catch (_) {
      return null;
    }
  }

  bool isDownloadedLocally(String ebookId) {
    final box = Hive.box('offline_ebooks');
    return box.containsKey(ebookId);
  }

  String? getLocalPath(String ebookId) {
    final box = Hive.box('offline_ebooks');
    return box.get(ebookId) as String?;
  }
}
