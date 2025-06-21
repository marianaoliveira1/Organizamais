import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/pages/initial/widget/fixed_accounts.dart';
import 'package:organizamais/pages/initial/widget/title_card.dart';

import '../../../controller/fixed_accounts_controller.dart';

class DefaultWidgetFixedAccounts extends StatelessWidget {
  const DefaultWidgetFixedAccounts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 14.w,
      ),
      child: Column(
        children: [
          DefaultTitleCard(
            text: "Contas fixas",
            onTap: () {
              Get.toNamed("/fixed-accounts");
            },
          ),
          SizedBox(
            height: 10.h,
          ),
          FixedAccounts(),
        ],
      ),
    );
  }
}
