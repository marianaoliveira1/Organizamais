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
    // Usar a instância existente do controller ao invés de criar uma nova
    // Isso evita substituir a instância que já tem o stream iniciado
    if (!Get.isRegistered<FixedAccountsController>()) {
      Get.put(FixedAccountsController());
    }

    final controller = Get.find<FixedAccountsController>();

    // Garantir que o stream está iniciado
    if (controller.fixedAccountsStream == null) {
      controller.startFixedAccountsStream();
    }

    // final theme = Theme.of(context);

    return Obx(() {
      final count = controller.fixedAccounts.length;
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
