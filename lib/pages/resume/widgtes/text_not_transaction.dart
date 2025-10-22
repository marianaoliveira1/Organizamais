import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:iconsax/iconsax.dart';

import 'package:organizamais/utils/color.dart';

class DefaultTextNotTransaction extends StatelessWidget {
  const DefaultTextNotTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Nenhum lançamento no período",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Toque em ",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: DefaultColors.grey,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: DefaultColors.green,
                borderRadius: BorderRadius.circular(18.r),
              ),
              padding: EdgeInsets.all(5.w),
              child: Icon(
                Iconsax.add,
                color: DefaultColors.white,
                size: 16.sp,
              ),
            ),
          ],
        ),
        Text(
          " para adicionar um lançamento ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: DefaultColors.grey,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
