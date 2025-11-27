import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/card_controller.dart';
import '../../../utils/color.dart';
import 'payment_option.dart';

class PaymentTypePage extends StatelessWidget {
  final TextEditingController controller;

  const PaymentTypePage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CardController cardController = Get.find<CardController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Selecione o método de pagamento',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.primaryColor,
          ),
          onPressed: () {
            // Fechar qualquer snackbar aberto antes de navegar
            // para evitar LateInitializationError
            try {
              if (Get.isSnackbarOpen == true) {
                Get.closeCurrentSnackbar();
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
              } else {
                Navigator.of(context).pop();
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ),
      body: Column(
        children: [
          AdsBanner(),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cartões de crédito
                  if (cardController.card.isNotEmpty)
                    Obx(() {
                      if (cardController.card.isEmpty) {
                        return Container(
                          height: 150.h,
                          alignment: Alignment.center,
                          child: Text(
                            'Nenhum cartão adicionado',
                            style: TextStyle(
                              color: DefaultColors.grey20,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cardController.card.length,
                            separatorBuilder: (context, index) => SizedBox(
                              height: 14.h,
                            ),
                            itemBuilder: (context, index) {
                              final card = cardController.card[index];

                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  color: theme.cardColor,
                                ),
                                child: ListTile(
                                  leading: Image.asset(
                                    card.iconPath!,
                                    width: 28.w,
                                    height: 28.h,
                                  ),
                                  title: Text(
                                    card.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    // Retorna o nome e o ícone do cartão selecionado
                                    // Fechar qualquer snackbar aberto antes de navegar
                                    try {
                                      if (Get.isSnackbarOpen == true) {
                                        Get.closeCurrentSnackbar();
                                        Future.delayed(
                                            const Duration(milliseconds: 200),
                                            () {
                                          if (context.mounted) {
                                            Navigator.of(context).pop({
                                              'title': card.name,
                                              'assetPath': card.iconPath,
                                            });
                                          }
                                        });
                                      } else {
                                        Navigator.of(context).pop({
                                          'title': card.name,
                                          'assetPath': card.iconPath,
                                        });
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        Navigator.of(context).pop({
                                          'title': card.name,
                                          'assetPath': card.iconPath,
                                        });
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }),

                  PaymentOption(
                    title: 'Débito',
                    assetPath: 'assets/icon-category/debito.png',
                    controller: controller,
                  ),
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

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
