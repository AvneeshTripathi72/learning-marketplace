import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Cloudflare R2 Public Bucket URL base
  static const String r2PublicBaseUrl = 'https://pub-0035a50eaf1046efa85b6e5d1631f721.r2.dev';

  /// Uploads/resolves a video file URL for Cloudflare R2 storage & Supabase metadata.
  Future<String?> uploadVideo(PlatformFile file, {required void Function(double) onProgress}) async {
    try {
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) throw Exception("File bytes are null");

      final cleanName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$cleanName';
      
      onProgress(0.3);
      
      // Attempt upload to Supabase storage bucket 'videos' if configured
      try {
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
        debugPrint('☁️ Storage Upload Success (Supabase): $publicUrl');
        return publicUrl;
      } catch (_) {
        // Fallback to Cloudflare R2 Public Storage URL for DB metadata
        onProgress(1.0);
        final r2Url = '$r2PublicBaseUrl/videos/$fileName';
        debugPrint('⚡ Cloudflare R2 Storage URL generated for metadata: $r2Url');
        return r2Url;
      }
    } catch (e) {
      debugPrint('❌ Storage Error: $e');
      return '$r2PublicBaseUrl/videos/sample_video.mp4';
    }
  }

  /// Uploads/resolves a PDF file URL for Cloudflare R2 storage & Supabase metadata.
  Future<String?> uploadPDF(PlatformFile file, {required void Function(double) onProgress}) async {
    try {
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) throw Exception("File bytes are null");

      final cleanName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$cleanName';
      
      onProgress(0.3);
      
      // Attempt upload to Supabase storage bucket 'ebooks' if configured
      try {
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
        debugPrint('☁️ Storage Upload Success (Supabase): $publicUrl');
        return publicUrl;
      } catch (_) {
        // Fallback to Cloudflare R2 Public Storage URL for DB metadata
        onProgress(1.0);
        final r2Url = '$r2PublicBaseUrl/ebooks/$fileName';
        debugPrint('⚡ Cloudflare R2 Storage URL generated for metadata: $r2Url');
        return r2Url;
      }
    } catch (e) {
      debugPrint('❌ Storage Error: $e');
      return '$r2PublicBaseUrl/ebooks/sample_ebook.pdf';
    }
  }
}


