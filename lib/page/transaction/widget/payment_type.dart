import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/card_controller.dart';
import '../../../utils/color.dart';

class PaymentTypeField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentTypeField({
    super.key,
    required this.controller,
  });

  void _showPaymentOptions(BuildContext context) {
    final CardController cardController = Get.find<CardController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: DefaultColors.white,
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
                    color: Colors.black,
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
                            child: Text('Nenhum cartão adicionado'),
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
                                borderRadius: BorderRadius.circular(16.r),
                                color: DefaultColors.backgroundIght,
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
                                        color: Colors.black,
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
                    _buildPaymentOption(
                      context,
                      'Dinheiro',
                      'assets/icon-payment/money.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'Pix',
                      'assets/icon-payment/pix.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'Boleto',
                      'assets/icon-payment/fatura.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'Vale Refeição',
                      'assets/icon-payment/cartoes-de-credito.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'TED',
                      'assets/icon-payment/ted.png',
                      controller,
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

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String assetPath,
    TextEditingController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: DefaultColors.backgroundIght,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 4.h,
        horizontal: 10.w,
      ),
      margin: EdgeInsets.only(bottom: 14.h),
      child: ListTile(
        leading: Image.asset(
          assetPath,
          width: 22.w,
          height: 22.h,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          controller.text = title;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Selecione o tipo de pagamento",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.payment,
          color: DefaultColors.grey,
        ),
      ),
      onTap: () => _showPaymentOptions(context),
    );
  }
}
