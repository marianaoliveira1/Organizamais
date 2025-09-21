import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:organizamais/pages/initial/widget/my_card_widget.dart';

import '../../../controller/card_controller.dart';
import '../pages/add_card_page.dart';
// import 'title_card.dart';
import 'package:organizamais/widgetes/info_card.dart';

class CreditCardSection extends StatelessWidget {
  final CardController cardController = Get.find<CardController>();

  CreditCardSection({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Obx(() {
      final count = cardController.card.length;
      return InfoCard(
        title: 'Meus Cartões ($count)',
        icon: Icons.add,
        onTap: () {
          Get.to(
            () => AddCardPage(
              isEditing: false,
            ),
          );
        },
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyCardsWidget(
              cardController: cardController,
            ),
          ],
        ),
      );
    });
  }
}
