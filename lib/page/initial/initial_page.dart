import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/initial/widget/finance_summary.dart';
import 'package:organizamais/page/initial/widget/fixed_accounts.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/card_controller.dart';
import '../../controller/fixed_accounts_controller.dart';
import '../../model/cards_model.dart';
import 'pages/bank.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());
    final CardController cardController = Get.put(CardController());

    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20.w,
                horizontal: 20.h,
              ),
              child: Column(
                spacing: 20.h,
                children: [
                  FinanceSummaryWidget(),
                  DefaultWidgetFixedAccounts(),
                  CreditCardSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCardItem extends StatelessWidget {
  final CardsModel card;

  const CreditCardItem({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Encontra o banco correspondente ao ícone
    final bank = banks.firstWhere(
      (bank) => bank['id'] == card.icon,
      orElse: () => banks.first,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone do banco
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Image.asset(
              bank['icon'],
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          // Informações do cartão
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: DefaultColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Limite: R\$ ${card.limit}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: DefaultColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreditCardSection extends StatelessWidget {
  final CardController cardController = Get.find<CardController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          // Cabeçalho
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 16.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Meus Cartões",
                  style: TextStyle(
                    color: DefaultColors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.toNamed("/credit-card");
                  },
                  icon: Icon(Icons.add),
                )
              ],
            ),
          ),
          // Lista de cartões
          Obx(
            () => cardController.card.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Text(
                        'Nenhum cartão cadastrado',
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    itemCount: cardController.card.length,
                    itemBuilder: (context, index) {
                      final card = cardController.card[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.credit_card,
                            color: DefaultColors.green,
                          ),
                          title: Text(
                            card.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Limite: ${card.limit}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: DefaultColors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Ícone de editar
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Get.toNamed("/credit-card", arguments: card);
                                },
                              ),
                              // Ícone de excluir
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Get.toNamed(
                                    "/credit-card",
                                    arguments: card.copyWith(title: card.title ?? ''),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DefaultWidgetFixedAccounts extends StatelessWidget {
  const DefaultWidgetFixedAccounts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contas fixas",
                style: TextStyle(
                  color: DefaultColors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed("/fixed-accounts");
                },
                child: Icon(
                  Icons.add,
                  size: 16.sp,
                  color: DefaultColors.grey,
                ),
              ),
            ],
          ),
          FixedAccounts(
            fixedAccounts: Get.find<FixedAccountsController>().fixedAccounts,
          ),
        ],
      ),
    );
  }
}
