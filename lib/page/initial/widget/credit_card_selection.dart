import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../../../controller/card_controller.dart';
import '../pages/add_card_page.dart';
import 'widghet_fixed_accoutns.dart';

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
                Obx(() {
                  if (cardController.card.isEmpty) {
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: Text('Nenhum cartão adicionado'),
                    );
                  } else {
                    return Container(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cardController.card.length,
                        itemBuilder: (context, index) {
                          final card = cardController.card[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
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
                              child: Container(
                                width: 200,
                                padding: EdgeInsets.all(16),
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
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
