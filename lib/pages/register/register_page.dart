import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/auth_controller.dart';
import '../../services/analytics_service.dart';
import '../../widgtes/default_button.dart';
import '../../widgtes/default_button_google.dart';
import '../../widgtes/default_continue_com.dart';
import '../../widgtes/default_text_field.dart';
import '../../widgetes/privacy_policy_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AnalyticsService _analyticsService = AnalyticsService();
  bool acceptedPrivacy = false;

  @override
  void initState() {
    super.initState();
    _analyticsService.logScreenView('register_page');
  }

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
    final theme = Theme.of(context);

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
            SizedBox(
              height: 120.h,
            ),
            Text(
              "ORGANIZA+",
              style: TextStyle(
                  color: DefaultColors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
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
              onTap: () {
                if (!acceptedPrivacy) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Você precisa aceitar a Política de Privacidade para continuar.')),
                  );
                  return;
                }
                authController.register(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                );
              },
            ),
            SizedBox(
              height: 28.h,
            ),
            DefaultContinueCom(),
            SizedBox(
              height: 20.h,
            ),
            ButtonLoginWithGoogle(
              text: "Cadastrar com Google",
              onTap: () {
                if (!acceptedPrivacy) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Você precisa aceitar a Política de Privacidade para continuar.')),
                  );
                  return;
                }
                authController.loginWithGoogle();
              },
            ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                checkColor: theme.cardColor,
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? theme.primaryColor
                      : null,
                ),
                value: acceptedPrivacy,
                onChanged: (v) {
                  setState(() => acceptedPrivacy = v ?? false);
                  if (v == true) {
                    _analyticsService.logPrivacyPolicyAccepted();
                  }
                },
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Concordo com os ",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: DefaultColors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _analyticsService.logPrivacyPolicyViewed();
                        showPrivacyPolicyDialog(context);
                      },
                      child: Text(
                        "Termos de Uso e Política de Privacidade",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: DefaultColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
