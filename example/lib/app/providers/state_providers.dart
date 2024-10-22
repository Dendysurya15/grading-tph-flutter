import 'package:ultralytics_yolo_example/app/providers/preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppRoute {
  welcome,
  login,
  home,
}

// Route Provider
final routeProvider = StateProvider<AppRoute>((ref) => AppRoute.welcome);
final sharedDataProvider = StateProvider<String?>((ref) => null);

// Loading Provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Location Provider
final locationStatusProvider = StateProvider<bool>((ref) => false);

// Shared Preferences Provider
final sharedPreferencesNotifierProvider =
    StateNotifierProvider<SharedPreferencesNotifier, void>(
  (ref) => SharedPreferencesNotifier(),
);
