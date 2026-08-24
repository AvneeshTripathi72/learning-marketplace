class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String profile = '/auth/me';

  // Publications
  static const String publications = '/publications';
  
  // Content
  static const String ebooks = '/ebooks';
  static const String youtubeVideos = '/videos/youtube';
  static const String questionPapers = '/generators/question-paper';
  static const String testPapers = '/generators/test-paper';
  
  // Public Hub
  static const String publicVideos = '/public-hub/videos';
  static const String categories = '/categories';
  
  // Monetization
  static const String subscriptions = '/subscriptions';
  static const String payments = '/payments';
  static const String donations = '/donations';
}
