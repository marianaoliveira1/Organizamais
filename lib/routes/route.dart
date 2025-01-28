import 'package:get/get.dart';

import '../page/home/home_page.dart';
import '../page/login/login_page.dart';
import '../page/register/register_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/register', page: () => const RegisterPage()),
    GetPage(name: '/home', page: () => const HomePage()),
  ];
}
