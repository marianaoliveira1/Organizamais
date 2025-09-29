// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
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
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    print('Error initializing MobileAds: $e');
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

  runApp(const MyApp());
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

    return ScreenUtilInit(
      designSize: const Size(375, 812),
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
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,

        // 🌞 Tema Claro
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(),
          brightness: Brightness.light,
          scaffoldBackgroundColor: DefaultColors.backgroundLight,
          primaryColor: DefaultColors.black,
          cardColor: DefaultColors.white,

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
