import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/auth_controller.dart';
import '../../widgtes/default_button.dart';
import '../../widgtes/default_button_google.dart';
import '../../widgtes/default_continue_com.dart';
import '../../widgtes/default_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: DefaultColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.h,
          vertical: 30.w,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 80.h,
              ),
              Text(
                "ORGANIZA+",
                style: TextStyle(
                  color: DefaultColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(
                height: 70.h,
              ),
              DefaultTextField(
                hintText: "Email",
                prefixIcon: Icon(Iconsax.sms),
                controller: emailController,
              ),
              SizedBox(height: 20.h),
              DefaultTextField(
                hintText: "Senha",
                prefixIcon: Icon(Iconsax.lock),
                controller: passwordController,
              ),
              SizedBox(
                height: 20.h,
              ),
              DefaultButton(
                text: "Entrar",
                onTap: () => authController.login(
                  emailController.text,
                  passwordController.text,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              DefaultContinueCom(),
              SizedBox(
                height: 20.h,
              ),
              ButtonLoginWithGoogle(
                text: "Entrar com Google",
                onTap: () => authController.loginWithGoogle(),
              ),
              SizedBox(
                height: 60.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Não tem uma conta?",
                    style: TextStyle(
                      color: DefaultColors.grey,
                    ),
                  ),
                  SizedBox(
                    width: 3.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: Text(
                      "Cadastre-se",
                      style: TextStyle(
                        color: DefaultColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
