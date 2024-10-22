import 'package:ultralytics_yolo_example/app/data/repositories/login_repository.dart';
import 'package:ultralytics_yolo_example/app/providers/preferences_provider.dart';
import 'package:ultralytics_yolo_example/app/utils/app_keys.dart';
import 'package:ultralytics_yolo_example/app/utils/preferences_keys.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

class LoginState {
  final bool isSuccess;
  final String message;

  LoginState({
    required this.isSuccess,
    required this.message,
  });

  factory LoginState.initial() {
    return LoginState(
      isSuccess: false,
      message: '',
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginRepository _repository;
  final Ref _ref;

  LoginNotifier(this._repository, this._ref) : super(LoginState.initial());

  Future<void> loginOnline(String email, String password,
      SharedPreferencesNotifier sharedPrefsNotifier) async {
    // _ref.read(isLoadingProvider.notifier).state = true;

    try {
      final response = await _repository.login(email, password);
      if (response.success == 1) {
        if (response.data != null) {
          await sharedPrefsNotifier.saveValue(PreferencesKeys.email, email);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.password, password);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.userId, response.data!.userId);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.namaLengkap, response.data!.namaLengkap);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.department, response.data!.departemen);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.jabatan, response.data!.jabatan);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.afdeling, response.data!.afdeling);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.lokasiKerja, response.data!.lokasiKerja);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.nomorHp, response.data!.nomorHp);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.aksesLevel, response.data!.aksesLevel);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.departementId, response.data!.departementId);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.jabatanId, response.data!.jabatanId);
          await sharedPrefsNotifier.saveValue(
              PreferencesKeys.apiToken, response.data!.apiToken);
        }

        state = LoginState(
          isSuccess: true,
          message: response.message,
        );
      } else {
        state = LoginState(
          isSuccess: false,
          message: response.message,
        );
      }
    } catch (e) {
      state = LoginState(
        isSuccess: false,
        message: 'An error occurred, error: $e',
      );
    } finally {
      // _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> loginOffline(String email, String password,
      SharedPreferencesNotifier sharedPrefsNotifier) async {
    // _ref.read(isLoadingProvider.notifier).state = true;

    try {
      String spEmail =
          await sharedPrefsNotifier.loadValue(PreferencesKeys.email) ?? '';
      String spPassword =
          await sharedPrefsNotifier.loadValue(PreferencesKeys.password) ?? '';

      if (spEmail.isNotEmpty && spPassword.isNotEmpty) {
        if (spEmail == email && spPassword == password) {
          state = LoginState(
            isSuccess: true,
            message: 'Login offline successfully',
          );
        } else {
          state = LoginState(
            isSuccess: false,
            message: 'Login failed, password or email is incorrect',
          );
        }
      } else {
        state = LoginState(
          isSuccess: false,
          message: 'Nothing account found',
        );
      }
    } catch (e) {
      state = LoginState(
        isSuccess: false,
        message: 'An error occurred offline, error: $e',
      );
    } finally {
      // _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final LocalAuthentication localAuth = LocalAuthentication();
      bool authenticated = await localAuth.authenticate(
        localizedReason: 'Scan your fingerprint (or face) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        state = LoginState(
          isSuccess: true,
          message: 'Biometric authentication successful',
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  void resetState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = LoginState(isSuccess: false, message: '');
    });
  }
}

final loginRepositoryProvider = Provider((ref) => LoginRepository());
final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.read(loginRepositoryProvider), ref);
});
