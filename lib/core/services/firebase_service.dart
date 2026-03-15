import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:wellness_ai/core/constants/app_constants.dart';

class FirebaseService {
  FirebaseRemoteConfig? _remoteConfig;

  FirebaseRemoteConfig? get remoteConfig => _remoteConfig;

  Future<void> init() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // Set default values from our constants
    await _remoteConfig!.setDefaults(AppConstants.defaultSystemInstructions);

    // Fetch and activate
    try {
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      // If fetch fails, defaults from setDefaults will be used
    }
  }

  String getSystemInstruction(String key) {
    if (_remoteConfig == null) {
      // Firebase not initialized — return hardcoded default
      return AppConstants.defaultSystemInstructions[key] ?? '';
    }
    final value = _remoteConfig!.getString(key);
    if (value.isNotEmpty) {
      return value;
    }
    return AppConstants.defaultSystemInstructions[key] ?? '';
  }
}
