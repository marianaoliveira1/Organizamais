import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../widgtes/default_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.h,
          vertical: 30.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            DefaultButton(),
            SizedBox(
              height: 20.h,
            ),
            InkWell(
              onTap: () {},
              child: Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: DefaultColors.white,
                  borderRadius: BorderRadius.circular(
                    24.r,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.activity,
                      color: DefaultColors.black,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      "Entrar com Google",
                      style: TextStyle(
                        color: DefaultColors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: DefaultColors.black,
          borderRadius: BorderRadius.circular(
            24.r,
          ),
        ),
        child: Center(
          child: Text(
            "Entrar",
            style: TextStyle(
              color: DefaultColors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
