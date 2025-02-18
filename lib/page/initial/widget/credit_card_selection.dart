import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../../../controller/card_controller.dart';
import '../pages/add_card_page.dart';
import 'title_card.dart';

class CreditCardSection extends StatelessWidget {
  final CardController cardController = Get.find<CardController>();

  CreditCardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
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
                  height: 8.h,
                ),
                MyCardsWidget(
                  cardController: cardController,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyCardsWidget extends StatelessWidget {
  const MyCardsWidget({
    super.key,
    required this.cardController,
  });

  final CardController cardController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            if (cardController.card.isEmpty) {
              return Container(
                height: 150,
                alignment: Alignment.center,
                child: Text('Nenhum cartão adicionado'),
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
                    Get.to(() => AddCardPage(
                          isEditing: true,
                          card: card,
                        ));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (card.iconPath != null)
                            Image.asset(
                              card.iconPath!,
                              width: 40,
                              height: 40,
                            ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              card.name,
                              style: TextStyle(
                                color: DefaultColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
