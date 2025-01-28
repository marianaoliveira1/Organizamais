import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

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
