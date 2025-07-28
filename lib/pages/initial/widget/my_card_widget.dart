import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../controller/card_controller.dart';
import '../../../utils/color.dart';
import '../pages/add_card_page.dart';

class MyCardsWidget extends StatelessWidget {
  const MyCardsWidget({
    super.key,
    required this.cardController,
  });

  final CardController cardController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            if (cardController.card.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum cartão adicionado',
                  style: TextStyle(
                    color: DefaultColors.grey20,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cardController.card.length,
              separatorBuilder: (context, index) => SizedBox(
                height: 12.h,
              ),
              itemBuilder: (context, index) {
                final card = cardController.card[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: theme.cardColor,
                        content: Text(
                            'Tem certeza que deseja excluir o cartão ${card.name}?'),
                        actions: [
                          TextButton(
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 12.sp,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Excluir',
                              style: TextStyle(
                                color: DefaultColors.grey20,
                                fontSize: 12.sp,
                              ),
                            ),
                            onPressed: () {
                              cardController.deleteCard(card.id!);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: () {
                    Get.to(
                      () => AddCardPage(
                        isEditing: true,
                        card: card,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (card.iconPath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.asset(
                                card.iconPath!,
                                width: 36.w,
                                height: 36.h,
                              ),
                            ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            child: Text(
                              card.name,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
