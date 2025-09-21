import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:organizamais/pages/initial/widget/fixed_accounts.dart';

import '../../../controller/fixed_accounts_controller.dart';
import '../../../widgetes/info_card.dart';

class DefaultWidgetFixedAccounts extends StatelessWidget {
  const DefaultWidgetFixedAccounts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    // final theme = Theme.of(context);

    return Obx(() {
      final count = Get.find<FixedAccountsController>().fixedAccounts.length;
      return InfoCard(
        title: "Contas fixas ($count)",
        onTap: () {
          Get.toNamed("/fixed-accounts");
        },
        icon: Iconsax.add,
        content: FixedAccounts(),
      );
    });
  }
}
