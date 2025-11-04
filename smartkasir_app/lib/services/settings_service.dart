import 'package:smartkasir_app/data/local_db.dart';
import 'package:smartkasir_app/models/settings.dart';

class SettingsService {
  Future<Settings> fetchSettings() async {
    final map = await LocalDB.getSettings();
    return Settings.fromMap(map);
  }

  Future<Settings> saveSettings(Settings settings) async {
    final savedMap = await LocalDB.saveSettings(settings.toMap());
    return Settings.fromMap(savedMap);
  }

  Future<void> resetDatabase() async {
    await LocalDB.resetDatabase();
  }

  Future<void> clearAllData() async {
    await LocalDB.clearAllData();
  }
}
