// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/controller/goal_controller.dart';
import 'package:organizamais/controller/spending_goal_controller.dart';
import 'package:organizamais/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:organizamais/utils/color.dart';

import 'controller/auth_controller.dart';
import 'controller/card_controller.dart';
import 'controller/transaction_controller.dart';
import 'routes/route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/messaging_service.dart';
import 'services/remote_config_service.dart';
import 'services/performance_service.dart';

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();

    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      print('Error initializing Firebase: $e');
    }

    // Configure Crashlytics collection and global error handlers
    try {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      // Forward Flutter framework errors to Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        // Check if this is an AssetManifest.json error - don't crash the app for this
        final isAssetManifestError =
            details.exception.toString().contains('AssetManifest.json') ||
                details.exception.toString().contains('Unable to load asset');

        if (isAssetManifestError) {
          // Log to Crashlytics but don't present the error to the user
          // This prevents the app from crashing due to Google Fonts asset loading issues
          try {
            FirebaseCrashlytics.instance.recordError(
              details.exception,
              details.stack ?? StackTrace.current,
              reason: 'AssetManifest.json error (non-fatal)',
              fatal: false,
            );
          } catch (_) {
            // Ignore if Crashlytics is not available
          }
          debugPrint(
              'AssetManifest.json error caught (non-fatal): ${details.exception}');
          return; // Don't present the error or crash the app
        }

        // For other errors, present and log normally
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterError(details);
      };

      // Catch unhandled async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('Crashlytics setup failed: $e');
    }

    if (kReleaseMode) {
      try {
        await MobileAds.instance.initialize();
      } catch (e) {
        print('Error initializing MobileAds: $e');
      }
    } else {
      debugPrint('MobileAds disabled in debug mode');
    }

    try {
      initializeDateFormatting('pt_BR', null);
    } catch (e) {
      print('Error initializing date formatting: $e');
    }

    try {
      await NotificationService().init();
    } catch (e) {
      print('Error initializing notifications: $e');
    }

    // Initialize Firebase services
    AnalyticsService();
    await RemoteConfigService().init();
    await PerformanceService().init();
    await MessagingService().init();
    // Debug: print FCM token
    if (kDebugMode) {
      try {
        final token = await MessagingService().getToken();
        debugPrint('FCM token: $token');
      } catch (_) {}
    }

    runApp(const MyApp());
  }, (Object error, StackTrace stack) async {
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (e) {
      debugPrint('Failed to record zone error to Crashlytics: $e');
    }
  });
}

/// Helper function to safely load Google Fonts with fallback
/// This function wraps GoogleFonts calls in a try-catch to prevent crashes
/// when AssetManifest.json is not available (common in some build scenarios)
///
/// The error "Unable to load asset: AssetManifest.json" can occur when:
/// - The app hasn't been properly built after changes
/// - Assets are not included in the build
/// - GoogleFonts tries to load before assets are available
TextTheme _getTextTheme() {
  try {
    // Usa Inter baseada no TextTheme padrão
    final base = ThemeData.light().textTheme;
    final textTheme = GoogleFonts.interTextTheme(base);

    return textTheme;
  } catch (e, stackTrace) {
    // Envia erro ao Crashlytics (sem travar o app)
    try {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to load Google Fonts',
        fatal: false,
      );
    } catch (_) {}

    debugPrint('Error loading Google Fonts, applying fallback.');
    // fallback em caso de erro
    return _createInterTextTheme(ThemeData.light().textTheme);
  }
}

/// Helper function to safely load Google Fonts for dark theme with fallback
TextTheme _getDarkTextTheme() {
  try {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    // Verificar se a fonte foi aplicada corretamente
    if (textTheme.bodyLarge?.fontFamily != null) {
      return textTheme;
    }
    // Se não foi aplicada, criar manualmente com fonte Inter
    return _createInterTextTheme(ThemeData.dark().textTheme);
  } catch (e, stackTrace) {
    try {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason:
              'Failed to load Google Fonts (dark) - AssetManifest.json error',
          fatal: false,
        );
      }
    } catch (_) {
      // Ignore if Crashlytics is not available
    }
    debugPrint(
        'Error loading Google Fonts (dark) (applying Inter manually): $e');
    // Criar TextTheme manualmente com fonte Inter mesmo em caso de erro
    return _createInterTextTheme(ThemeData.dark().textTheme);
  }
}

/// Cria um TextTheme com fonte Inter aplicada manualmente
/// Isso garante que a fonte Inter seja sempre usada, mesmo se Google Fonts falhar
TextTheme _createInterTextTheme(TextTheme baseTheme) {
  // Sempre tentar aplicar Inter através do Google Fonts
  // Mesmo que tenha falhado antes, tentar novamente aqui
  try {
    return GoogleFonts.interTextTheme(baseTheme);
  } catch (_) {
    // Se ainda falhar, retornar o baseTheme mas com fontFamily definida
    // O fontFamily será aplicado no ThemeData principal
    return baseTheme;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(FixedAccountsController());
    Get.put(CardController());
    Get.put(TransactionController());
    Get.put(GoalController());
    Get.put(SpendingGoalController());

    // Verificar usuário atual ANTES de definir a rota inicial
    final currentUser = FirebaseAuth.instance.currentUser;
    final String initialRoute =
        currentUser != null ? Routes.HOME : Routes.LOGIN;

    return ScreenUtilInit(
      designSize: Size(390, 815),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: 'Organiza+',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('pt', 'BR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: initialRoute,
        getPages: AppPages.routes,

        // 🌞 Tema Claro
        theme: ThemeData(
          textTheme: _getTextTheme(),
          fontFamily: 'Inter',
          brightness: Brightness.light,
          scaffoldBackgroundColor: DefaultColors.white,
          primaryColor: DefaultColors.black,
          cardColor: DefaultColors.backgroundLight,

          // Cursor piscando e seleção
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: DefaultColors.black,
            selectionColor: DefaultColors.black,
            selectionHandleColor: DefaultColors.black,
          ),

          // ProgressIndicator sempre na cor primária
          progressIndicatorTheme: const ProgressIndicatorThemeData(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: DefaultColors.black,
            brightness: Brightness.light,
          ),
        ),

        // 🌙 Tema Escuro
        darkTheme: ThemeData(
          textTheme: _getDarkTextTheme(),
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: DefaultColors.backgroundDark,
          primaryColor: DefaultColors.white,
          cardColor: DefaultColors.backgroundCard,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: DefaultColors.white,
            selectionColor: DefaultColors.white.withOpacity(0.3),
            selectionHandleColor: DefaultColors.white,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: DefaultColors.white,
            brightness: Brightness.dark,
          ),
        ),
      ),
    );
  }
}
