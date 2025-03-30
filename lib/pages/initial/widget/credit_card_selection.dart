import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:organizamais/pages/initial/widget/my_card_widget.dart';

import '../../../controller/card_controller.dart';
import '../pages/add_card_page.dart';
import 'title_card.dart';

class CreditCardSection extends StatelessWidget {
  final CardController cardController = Get.find<CardController>();

  CreditCardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
          horizontal: 14.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTitleCard(
              text: "Meus Cartões",
              onTap: () {
                Get.to(
                  () => AddCardPage(
                    isEditing: false,
                  ),
                );
              },
            ),
            SizedBox(
              height: 10.h,
            ),
            MyCardsWidget(
              cardController: cardController,
            ),
          ],
        ),
      ),
    );
  }
}
