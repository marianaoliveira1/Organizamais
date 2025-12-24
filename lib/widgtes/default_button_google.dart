import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

class ButtonLoginWithGoogle extends StatelessWidget {
  final String text;
  final void Function() onTap;
  final double? textSize;

  const ButtonLoginWithGoogle({
    super.key,
    required this.text,
    required this.onTap,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48.h,
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
              height: 36.h,
              width: 25.w,
            ),
            SizedBox(
              width: 12.w,
            ),
            Text(
              text,
              style: TextStyle(
                color: DefaultColors.black,
                fontSize: (textSize ?? 15).sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonLoginWithApple extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? textSize;

  const ButtonLoginWithApple({
    super.key,
    required this.text,
    required this.onTap,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: DefaultColors.black,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple,
              color: DefaultColors.white,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                color: DefaultColors.white,
                fontSize: (textSize ?? 12).sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
