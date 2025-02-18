import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/page/initial/widget/fixed_accounts.dart';
import 'package:organizamais/utils/color.dart';

import '../../../controller/fixed_accounts_controller.dart';

class DefaultWidgetFixedAccounts extends StatelessWidget {
  const DefaultWidgetFixedAccounts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
      ),
      child: Column(
        children: [
          DefaultTitleCard(
            text: "Contas fixas",
            onTap: () {
              Get.toNamed("/fixed-accounts");
            },
          ),
          FixedAccounts(
            fixedAccounts: Get.find<FixedAccountsController>().fixedAccounts,
          ),
        ],
      ),
    );
  }
}

class DefaultTitleCard extends StatelessWidget {
  final String text;
  void Function() onTap;

  DefaultTitleCard({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: DefaultColors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Icon(
            Icons.add,
            size: 16.sp,
            color: DefaultColors.grey,
          ),
        ),
      ],
    );
  }
}
