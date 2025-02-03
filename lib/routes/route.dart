import 'package:get/get.dart';

import '../page/cards/cards_page.dart';
import '../page/graphics/graphics_page.dart';
import '../page/home/home_page.dart';
import '../page/initial/initial_page.dart';
import '../page/login/login_page.dart';
import '../page/register/register_page.dart';
import '../page/resume/resume_pegae.dart';
import '../page/transaction_page.dart/transaction_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/register', page: () => const RegisterPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/initial', page: () => const InitialPage()),
    GetPage(name: '/charts', page: () => GraphicsPage()),
    GetPage(name: '/card', page: () => CardsPage()),
    GetPage(name: '/resume', page: () => ResumePegae()),
    GetPage(name: '/transaction', page: () => TransactionPage()),
  ];
}
