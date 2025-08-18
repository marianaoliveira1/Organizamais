// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:organizamais/pages/profile/pages/fixed_accounts_page.dart';
import 'package:organizamais/pages/profile/profile_page.dart';

import '../pages/cards/cards_page.dart';
import '../pages/graphics/graphics_page.dart';
import '../pages/home/home_page.dart';

import '../pages/initial/initial_page.dart';

import '../pages/initial/pages/fixed_accotuns_page.dart';

import '../pages/login/login_page.dart';
import '../pages/register/register_page.dart';

import '../pages/resume/resume_page.dart';
import '../pages/transaction/pages/category_page.dart';
import '../pages/transaction/transaction_page.dart';
import '../pages/onboarding/onboarding_welcome_page.dart';
import '../pages/onboarding/onboarding_card_intro_page.dart';
import '../pages/onboarding/onboarding_card_success_page.dart';
import '../pages/onboarding/onboarding_fixed_success_page.dart';

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
  static const FIXED_ACCOUNTS_PAGE = '/fixed-accounts-page';
  static const PROFILE = '/profile';
  static const ADDGOALPAGE = '/add-goal';
  static const ONBOARD_WELCOME = '/onboard-welcome';
  static const CARD_INTRO = '/card-intro';
  static const CARD_SUCCESS = '/card-success';
  static const FIXED_SUCCESS = '/fixed-success';
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
    GetPage(name: Routes.CATEGORY, page: () => CategoryPage()),
    GetPage(
        name: Routes.FIXED_ACCOUNTS, page: () => AddFixedAccountsFormPage()),
    GetPage(name: Routes.PROFILE, page: () => ProfilePage()),
    GetPage(
        name: Routes.FIXED_ACCOUNTS_PAGE,
        page: () => const FixedAccountsPage()),
    GetPage(
        name: Routes.ONBOARD_WELCOME,
        page: () => const OnboardingWelcomePage()),
    GetPage(
        name: Routes.CARD_INTRO, page: () => const OnboardingCardIntroPage()),
    GetPage(
        name: Routes.CARD_SUCCESS,
        page: () => const OnboardingCardSuccessPage()),
    GetPage(
        name: Routes.FIXED_SUCCESS,
        page: () => const OnboardingFixedSuccessPage()),
    // GetPage(name: Routes.ADDGOALPAGE, page: () => AddGoalPage()),
  ];

  static const INITIAL = Routes.LOGIN;
}
