import 'package:ultralytics_yolo_example/app/data/services/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedPreferencesNotifier extends StateNotifier<void> {
  SharedPreferencesNotifier() : super(null);

  Future<void> saveValue(String key, dynamic value) async {
    final manager = await SharedPreferencesManager.getInstance();
    await manager.saveValue(key, value);
  }

  Future<dynamic> loadValue(String key) async {
    final manager = await SharedPreferencesManager.getInstance();
    return manager.loadValue(key);
  }

  // Method to remove value
  Future<void> removeValue(String key) async {
    final manager = await SharedPreferencesManager.getInstance();
    await manager.removeValue(key);
  }

  // Method to clear all values
  Future<void> clearAllValues() async {
    final manager = await SharedPreferencesManager.getInstance();
    await manager.clearAllValues();
    state = null;
  }
}
