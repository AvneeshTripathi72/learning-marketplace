import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Open default boxes
    await Hive.openBox('settings');
    await Hive.openBox('offline_ebooks');
  }

  Box get settingsBox => Hive.box('settings');
  Box get ebooksBox => Hive.box('offline_ebooks');
}
