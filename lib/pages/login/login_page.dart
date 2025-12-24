import 'dart:math';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AnalyticsService _analyticsService = AnalyticsService();
  bool acceptedPrivacy = false;
  String? _formErrorMessage;

  @override
  void initState() {
    super.initState();
    _analyticsService.logScreenView('login_page');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AuthController authController = Get.find();

    const double wideBreakpoint = 700;

    return Scaffold(
      backgroundColor: DefaultColors.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= wideBreakpoint;
            final double horizontalPadding =
                isWide ? max((constraints.maxWidth - 520) / 2, 48) : 24.w;
            final double verticalPadding = isWide ? 40 : 24.h;
            final TextStyle headingStyle = TextStyle(
              color: DefaultColors.black,
              fontWeight: FontWeight.bold,
              fontSize: isWide ? 28 : 16.sp,
            );
            final bool showAppleSignIn =
                GetPlatform.isIOS || GetPlatform.isMacOS;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 520 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: isWide ? 60 : 150.h),
                              Text(
                                "ORGANIZA+",
                                textAlign: TextAlign.center,
                                style: headingStyle,
                              ),
                              SizedBox(height: isWide ? 40 : 70.h),
                              DefaultTextField(
                                hintText: "Email",
                                prefixIcon: Icon(Iconsax.sms),
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              SizedBox(height: 24.h),
                              DefaultTextField(
                                hintText: "Senha",
                                prefixIcon: Icon(Iconsax.lock),
                                controller: passwordController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) =>
                                    _submitLogin(authController),
                              ),
                              SizedBox(height: 24.h),
                              DefaultButton(
                                text: "Entrar",
                                onTap: () => _submitLogin(authController),
                              ),
                              if (_formErrorMessage != null) ...[
                                SizedBox(height: 12.h),
                                Text(
                                  _formErrorMessage!,
                                  style: TextStyle(
                                    color: DefaultColors.red,
                                    fontSize: 13.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 30.h),
                              const DefaultContinueCom(),
                              SizedBox(height: 20.h),
                              ButtonLoginWithGoogle(
                                text: "Entrar com Google",
                                onTap: () {
                                  if (!acceptedPrivacy) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Você precisa aceitar a Política de Privacidade para continuar.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  authController.loginWithGoogle();
                                },
                              ),
                              if (showAppleSignIn) ...[
                                SizedBox(height: 16.h),
                                ButtonLoginWithApple(
                                  text: "Entrar com Apple",
                                  onTap: () {
                                    if (!acceptedPrivacy) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Você precisa aceitar a Política de Privacidade para continuar.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    authController.loginWithApple();
                                  },
                                ),
                              ],
                              SizedBox(height: 36.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Não tem uma conta?",
                                    style: TextStyle(
                                      color: DefaultColors.grey,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, "/register"),
                                    child: Text(
                                      "Cadastre-se",
                                      style: TextStyle(
                                        color: DefaultColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 520 : double.infinity,
                    ),
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
                                  fontSize: 12.sp,
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
                                    fontSize: 12.sp,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitLogin(AuthController authController) async {
    if (authController.isLoading.value) return;
    FocusScope.of(context).unfocus();

    const privacyMessage =
        'Você precisa aceitar a Política de Privacidade para continuar.';
    if (!acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(privacyMessage)),
      );
      setState(() => _formErrorMessage = privacyMessage);
      return;
    }

    setState(() => _formErrorMessage = null);
    final errorMessage = await authController.login(
      emailController.text,
      passwordController.text,
    );
    if (!mounted) return;
    if (errorMessage != null) {
      setState(() => _formErrorMessage = errorMessage);
    }
  }
}
