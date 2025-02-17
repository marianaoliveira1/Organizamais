import 'package:get/get.dart';

import '../page/cards/cards_page.dart';
import '../page/graphics/graphics_page.dart';
import '../page/home/home_page.dart';

import '../page/initial/initial_page.dart';

import '../page/initial/pages/fixed_accotuns_page.dart';
import '../page/login/login_page.dart';
import '../page/register/register_page.dart';

import '../page/resume/resume_pegae.dart';
import '../page/transaction/pages/  category.dart';
import '../page/transaction/transaction_page.dart';

class Routes {
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const INITIAL = '/initial';
  static const CHARTS = '/charts';
  static const CARD = '/card';
  static const RESUME = '/resume';
  static const TRANSACTION = '/transaction';
  static const CATEGORY = '/category';
  static const FIXED_ACCOUNTS = '/fixed-accounts';
  static const BANK = '/bank';
  static const CREDITCARD = '/credit-card';
}

class AppPages {
  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => const LoginPage()),
    GetPage(name: Routes.REGISTER, page: () => const RegisterPage()),
    GetPage(name: Routes.HOME, page: () => HomePage()),
    GetPage(name: Routes.INITIAL, page: () => const InitialPage()),
    GetPage(name: Routes.CHARTS, page: () => GraphicsPage()),
    GetPage(name: Routes.CARD, page: () => CardsPage()),
    GetPage(name: Routes.RESUME, page: () => ResumePage()),
    GetPage(name: Routes.TRANSACTION, page: () => TransactionPage()),
    GetPage(name: Routes.CATEGORY, page: () => Category()),
    GetPage(name: Routes.FIXED_ACCOUNTS, page: () => FixedAccotunsPage()),
    // GetPage(name: Routes.BANK, page: () => BankSearchPage()),
    // GetPage(name: Routes.CREDITCARD, page: () => CreditCardPage()),
  ];

  static const INITIAL = Routes.LOGIN;
}
