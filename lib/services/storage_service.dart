import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a video file to the 'videos' bucket and returns the public URL.
  Future<String?> uploadVideo(PlatformFile file, {required void Function(double) onProgress}) async {
    try {
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) throw Exception("File bytes are null");

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      
      onProgress(0.1);
      
      await _supabase.storage.from('videos').uploadBinary(
        fileName, 
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: file.name.endsWith('.mp4') ? 'video/mp4' : 'application/octet-stream',
        ),
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
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) throw Exception("File bytes are null");

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      
      onProgress(0.1);
      
      await _supabase.storage.from('ebooks').uploadBinary(
        fileName, 
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'application/pdf',
        ),
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
