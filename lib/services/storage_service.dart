import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a video file to the 'videos' bucket and returns the public URL.
  Future<String?> uploadVideo(PlatformFile file, {required void Function(double) onProgress}) async {
    try {
      if (file.path == null) throw Exception("File path is null");
      final fileData = File(file.path!);
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      
      // We simulate progress for UI purposes since direct streaming progress
      // from supabase storage upload might not be natively supported in all versions.
      onProgress(0.1);
      
      await _supabase.storage.from('videos').upload(
        fileName, 
        fileData,
        fileOptions: const FileOptions(upsert: true),
      );
      
      onProgress(1.0);

      final publicUrl = _supabase.storage.from('videos').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  /// Uploads a PDF file to the 'ebooks' bucket and returns the public URL.
  Future<String?> uploadPDF(PlatformFile file, {required void Function(double) onProgress}) async {
    try {
      if (file.path == null) throw Exception("File path is null");
      final fileData = File(file.path!);
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      
      onProgress(0.1);
      
      await _supabase.storage.from('ebooks').upload(
        fileName, 
        fileData,
        fileOptions: const FileOptions(upsert: true),
      );
      
      onProgress(1.0);

      final publicUrl = _supabase.storage.from('ebooks').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }
}
