import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/card_controller.dart';
import '../../../utils/color.dart';
import 'payment_option.dart';

class PaymentTypeField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentTypeField({
    super.key,
    required this.controller,
  });

  void _showPaymentOptions(BuildContext context) {
    final theme = Theme.of(context);

    final CardController cardController = Get.find<CardController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecione o método de pagamento',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    if (cardController.card.isNotEmpty)
                      Obx(() {
                        if (cardController.card.isEmpty) {
                          return Container(
                            height: 150,
                            alignment: Alignment.center,
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
                          itemCount: cardController.card.length * 2,
                          separatorBuilder: (context, index) => SizedBox(
                            height: 0.h,
                          ),
                          itemBuilder: (context, index) {
                            final card = cardController.card[index ~/ 2];
                            final isCredit = index.isEven;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  16.r,
                                ),
                                color: theme.scaffoldBackgroundColor,
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 4.h,
                                horizontal: 10.w,
                              ),
                              margin: EdgeInsets.only(
                                bottom: 14.h,
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Image.asset(
                                      card.iconPath!,
                                      width: 22.w,
                                      height: 22.h,
                                    ),
                                    title: Text(
                                      "${card.name} ${isCredit ? 'crédito' : 'débito'}",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      controller.text = card.name;
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    PaymentOption(
                      title: 'Dinheiro',
                      assetPath: 'assets/icon-payment/money.png',
                      controller: controller,
                    ),
                    PaymentOption(
                      title: 'Pix',
                      assetPath: 'assets/icon-payment/pix.png',
                      controller: controller,
                    ),
                    PaymentOption(
                      title: 'Boleto',
                      assetPath: 'assets/icon-payment/fatura.png',
                      controller: controller,
                    ),
                    PaymentOption(
                      title: 'Vale Refeição',
                      assetPath: 'assets/icon-payment/cartoes-de-credito.png',
                      controller: controller,
                    ),
                    PaymentOption(
                      title: 'TED',
                      assetPath: 'assets/icon-payment/ted.png',
                      controller: controller,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        fontSize: 16.sp,
        color: theme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Selecione o tipo de pagamento",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: DefaultColors.grey,
          fontWeight: FontWeight.w500,
        ),
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.payment,
          color: DefaultColors.grey,
          size: 24.w,
        ),
      ),
      onTap: () => _showPaymentOptions(context),
    );
  }
}
