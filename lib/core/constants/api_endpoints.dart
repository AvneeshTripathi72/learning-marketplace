class ApiEndpoints {
  static const String baseUrl = 'https://learning-marketplace.vercel.app/api/v1';
  
  // Supabase Config
  static const String supabaseUrl = 'https://nstuhceveajfvhkhzuhy.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zdHVoY2V2ZWFqZnZoa2h6dWh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg3MTIyMDcsImV4cCI6MjEwNDI4ODIwN30.nHQ2Klm7xO7c5AdZ6s2fmL7Y7NJOxO5Rs0We7fYrn-E';

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
