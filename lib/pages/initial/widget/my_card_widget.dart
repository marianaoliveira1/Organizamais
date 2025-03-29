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
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
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
                height: 14.h,
              ),
              itemBuilder: (context, index) {
                final card = cardController.card[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirmar exclusão'),
                        content: Text('Tem certeza que deseja excluir o cartão ${card.name}?'),
                        actions: [
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Excluir'),
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
                            Image.asset(
                              card.iconPath!,
                              width: 36.w,
                              height: 36.h,
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
                                fontSize: 13.sp,
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
