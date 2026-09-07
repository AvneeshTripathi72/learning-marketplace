import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_endpoints.dart';
import 'services/notification_service.dart';
import 'core/storage/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: ApiEndpoints.supabaseUrl,
    anonKey: ApiEndpoints.supabaseAnonKey,
  );

  try {
    await NotificationService().initialize();
  } catch (_) {}

  try {
    final count = await SecureStorageService().incrementAppLaunchCount();
    debugPrint('🚀 App Launch Count: $count');
  } catch (_) {}

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Publication & Education Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
