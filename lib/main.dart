// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:organizamais/utils/color.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'controller/auth_controller.dart';
import 'controller/card_controller.dart';
import 'controller/transaction_controller.dart';
import 'routes/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UnityAds.init(
    gameId: '5819004',
    onComplete: () => print('Initialization Complete'),
    onFailed: (error, message) {
      error.printError();
      message.printError();
      error.printInfo();
      message.printInfo();
      print('Initialization Failed: $error. $message');
    },
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeDateFormatting('pt_BR', null);

  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

    return ScreenUtilInit(
      designSize: const Size(360, 690),
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
        theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(),
          brightness: Brightness.light,
          scaffoldBackgroundColor: DefaultColors.backgroundLight,
          primaryColor: DefaultColors.black,
          cardColor: DefaultColors.white,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: DefaultColors.backgroundDark,
          primaryColor: DefaultColors.white,
          cardColor: DefaultColors.backgroundCard,
        ),
      ),
    );
  }
}
