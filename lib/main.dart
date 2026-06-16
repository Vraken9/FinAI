import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'core/services/supabase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // init Firebase
  // await Firebase.initializeApp(); // Uncomment when firebase_options is ready
  
  // init dotenv
  await dotenv.load(fileName: ".env");

  // init Supabase
  await SupabaseService().init();
  
  // Sentry aktif hanya jika dijalankan dengan:
  // flutter run --dart-define=SENTRY_DSN=<dsn-dari-PRD-04>
  // Untuk development tanpa Sentry, app tetap berjalan normal (lihat
  // PRD-04-ENVIRONMENT-SETUP.md untuk cara mendapatkan SENTRY_DSN)
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => runApp(const ProviderScope(child: FinAIApp())),
    );
  } else {
    // Sentry tidak dikonfigurasi (development tanpa DSN) — jalankan app
    // langsung tanpa Sentry, dan tampilkan log peringatan di console
    debugPrint('SENTRY_DSN tidak diset — Sentry error tracking nonaktif');
    runApp(const ProviderScope(child: FinAIApp()));
  }
  
  // Global error handling
  FlutterError.onError = (details) {
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Sentry.captureException(error, stackTrace: stack);
    return true;
  };
}
