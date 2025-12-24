// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'services/tracking_transparency_service.dart';

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Disable Google Fonts runtime fetching to prevent AssetManifest.json errors
    // Setting this to true allows downloading fonts if not found in assets
    GoogleFonts.config.allowRuntimeFetching = true;

    final trackingStatus =
        await const TrackingTransparencyService().ensurePromptBeforeTracking();
    debugPrint('ATT status: $trackingStatus');

    await _initializeFirebaseAndCrashlytics();

    if (kReleaseMode) {
      // Não bloquear o primeiro frame com inicialização de anúncios
      unawaited(_initializeMobileAds());
    } else {
      debugPrint('MobileAds disabled in debug mode');
    }

    try {
      initializeDateFormatting('pt_BR', null);
    } catch (e) {
      print('Error initializing date formatting: $e');
    }

    runApp(const MyApp());

    // Demais inicializações que não precisam travar o start da UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeSecondaryServices());
    });
  }, (Object error, StackTrace stack) async {
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (e) {
      debugPrint('Failed to record zone error to Crashlytics: $e');
    }
  });
}

Future<void> _initializeFirebaseAndCrashlytics() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  try {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Forward Flutter framework errors to Crashlytics
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Check if this is an AssetManifest.json error - don't crash the app for this
      final exceptionStr = details.exception.toString();
      final isAssetManifestError =
          exceptionStr.contains('AssetManifest.json') ||
              exceptionStr.contains('Unable to load asset') ||
              exceptionStr.contains('AssetBundle') ||
              exceptionStr.contains('font');

      if (isAssetManifestError) {
        // Log to Crashlytics but don't present the error to the user
        try {
          FirebaseCrashlytics.instance.recordError(
            details.exception,
            details.stack ?? StackTrace.current,
            reason: 'Asset/Font loading error (non-fatal)',
            fatal: false,
          );
        } catch (_) {}
        debugPrint(
            'Non-fatal asset/font error caught and silenced: $exceptionStr');
        return; // SILENCE the error completely
      }

      // For other errors, use original handler or default
      if (originalOnError != null) {
        originalOnError(details);
      } else {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterError(details);
      }
    };

    // Catch unhandled async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Crashlytics setup failed: $e');
  }
}

Future<void> _initializeSecondaryServices() async {
  try {
    await NotificationService().init();
  } catch (e) {
    print('Error initializing notifications: $e');
  }

  // Initialize Firebase services sem travar a renderização inicial
  AnalyticsService();
  try {
    await RemoteConfigService().init();
  } catch (e) {
    debugPrint('RemoteConfig init failed: $e');
  }
  try {
    await PerformanceService().init();
  } catch (e) {
    debugPrint('PerformanceService init failed: $e');
  }
  try {
    await MessagingService().init();
    if (kDebugMode) {
      try {
        final token = await MessagingService().getToken();
        debugPrint('FCM token: $token');
      } catch (_) {}
    }
  } catch (e) {
    debugPrint('MessagingService init failed: $e');
  }
}

Future<void> _initializeMobileAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('Error initializing MobileAds: $e');
  }
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

    // Force validation of at least one style to trigger potential error here
    if (textTheme.bodyLarge == null) throw Exception('GoogleFonts failed');

    return textTheme;
  } catch (e, stackTrace) {
    debugPrint('Error loading Google Fonts, applying fallback: $e');
    // Envia erro ao Crashlytics (sem travar o app)
    try {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to load Google Fonts (fallback applied)',
        fatal: false,
      );
    } catch (_) {}

    // fallback em caso de erro
    return _createFallbackTextTheme(Brightness.light);
  }
}

/// Helper function to safely load Google Fonts for dark theme with fallback
TextTheme _getDarkTextTheme() {
  try {
    final base = ThemeData.dark().textTheme;
    final textTheme = GoogleFonts.interTextTheme(base);

    // Force validation
    if (textTheme.bodyLarge == null) throw Exception('GoogleFonts failed');

    return textTheme;
  } catch (e, stackTrace) {
    debugPrint('Error loading Google Fonts (dark), applying fallback: $e');
    try {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to load Google Fonts dark (fallback applied)',
        fatal: false,
      );
    } catch (_) {}
    return _createFallbackTextTheme(Brightness.dark);
  }
}

/// Cria um TextTheme de fallback robusto
TextTheme _createFallbackTextTheme(Brightness brightness) {
  return (brightness == Brightness.light ? ThemeData.light() : ThemeData.dark())
      .textTheme;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _registerControllers();
  }

  void _registerControllers() {
    Get.put(AuthController(), permanent: true);
    Get.put(FixedAccountsController(), permanent: true);
    Get.put(CardController(), permanent: true);
    Get.put(TransactionController(), permanent: true);
    Get.put(GoalController(), permanent: true);
    Get.put(SpendingGoalController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    // Verificar usuário atual ANTES de definir a rota inicial
    final currentUser = FirebaseAuth.instance.currentUser;
    final String initialRoute =
        currentUser != null ? Routes.HOME : Routes.LOGIN;

    return ScreenUtilInit(
      designSize: Size(410, 915),
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
