enum AppRoute {
  welcome,
  login,
}

// Route Provider
final routeProvider = StateProvider<AppRoute>((ref) => AppRoute.welcome);
final sharedDataProvider = StateProvider<String?>((ref) => null);

// Loading Provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Location Provider
final locationStatusProvider = StateProvider<bool>((ref) => false);

final sharedPreferencesNotifierProvider =
    StateNotifierProvider<SharedPreferencesNotifier, void>(
  (ref) => SharedPreferencesNotifier(),
);
