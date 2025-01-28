import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class ButtonLoginWithGoogle extends StatelessWidget {
  const ButtonLoginWithGoogle({
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
          color: DefaultColors.white,
          borderRadius: BorderRadius.circular(
            24.r,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icon/google.png",
              height: 40.h,
              width: 25.w,
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
    );
  }
}
