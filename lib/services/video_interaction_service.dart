class VideoInteractionService {
  Future<bool> toggleLike(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> toggleSave(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<void> shareVideo(String videoId, String videoUrl) async {
    // Triggers native platform share sheet
  }
}
