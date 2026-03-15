import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/ai_service.dart';
import 'app/app.dart';

bool _hasValidFirebaseOptions(FirebaseOptions options) {
  // Placeholder values from template firebase_options.dart should not be used
  // to initialize Firebase, otherwise iOS can crash with native exceptions.
  final values = <String>[
    options.apiKey,
    options.appId,
    options.messagingSenderId,
    options.projectId,
  ];

  return values.every(
    (value) =>
        value.isNotEmpty &&
        !value.startsWith('YOUR-') &&
        !value.contains('YOUR_'),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize local storage
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Initialize Firebase (graceful — falls back to defaults if config is a placeholder)
  final firebaseService = FirebaseService();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  if (_hasValidFirebaseOptions(firebaseOptions)) {
    try {
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
      await firebaseService.init();
    } catch (_) {
      // Firebase not configured correctly; app will run in UI-preview mode.
    }
  } else {
    // Firebase is intentionally skipped until real options are provided.
  }

  // Initialize AI service
  final aiService = AiService(firebaseService: firebaseService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStorageService>.value(
          value: localStorageService,
        ),
        RepositoryProvider<FirebaseService>.value(
          value: firebaseService,
        ),
        RepositoryProvider<AiService>.value(
          value: aiService,
        ),
      ],
      child: const WellnessApp(),
    ),
  );
}
