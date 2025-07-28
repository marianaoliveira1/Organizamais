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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ORGANIZA+",
              style: TextStyle(
                color: DefaultColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 70.h,
            ),
            DefaultTextField(
              hintText: "Nome",
              prefixIcon: Icon(Iconsax.profile_circle4),
              controller: nameController,
            ),
            SizedBox(
              height: 20.h,
            ),
            DefaultTextField(
              hintText: "Email",
              prefixIcon: Icon(Iconsax.sms),
              controller: emailController,
            ),
            SizedBox(
              height: 20.h,
            ),
            DefaultTextField(
              hintText: "Senha",
              prefixIcon: Icon(Iconsax.lock),
              controller: passwordController,
            ),
            SizedBox(
              height: 20.h,
            ),
            DefaultButton(
              text: "Cadastrar",
              onTap: () => authController.register(
                nameController.text,
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
              text: "Cadastrar com Google",
              onTap: authController.loginWithGoogle,
            ),
            SizedBox(
              height: 60.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Já tem uma conta?",
                  style: TextStyle(
                    color: DefaultColors.grey,
                  ),
                ),
                SizedBox(
                  width: 3.w,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  child: Text(
                    "Entrar",
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
    );
  }
}
