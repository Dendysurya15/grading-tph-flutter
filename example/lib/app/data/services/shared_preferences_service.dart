import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  late SharedPreferences _prefs;

  SharedPreferencesManager._();

  static SharedPreferencesManager? _instance;

  static Future<SharedPreferencesManager> getInstance() async {
    _instance ??= await _initInstance();
    return _instance!;
  }

  static Future<SharedPreferencesManager> _initInstance() async {
    final manager = SharedPreferencesManager._();
    await manager._initPrefs();
    return manager;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  dynamic loadValue(String key) {
    return _prefs.get(key);
  }

  Future<bool> saveValue(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      return false;
    }
  }

  Future<bool> removeValue(String key) async {
    return await _prefs.remove(key);
  }

  Future<void> clearAllValues() async {
    await _prefs.clear();
  }
}
