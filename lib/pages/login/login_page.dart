import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../controller/auth_controller.dart';
import '../../widgtes/default_button.dart';
import '../../widgtes/default_button_google.dart';
import '../../widgtes/default_continue_com.dart';
import '../../widgtes/default_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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
            UnityBannerAd(
              placementId: 'Banner_Android',
              onLoad: (placementId) => print('Banner loaded: $placementId'),
              onClick: (placementId) => print('Banner clicked: $placementId'),
              onShown: (placementId) => print('Banner shown: $placementId'),
              onFailed: (placementId, error, message) => print('Banner Ad $placementId failed: $error $message'),
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
    );
  }
}
