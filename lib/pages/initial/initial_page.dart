import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/pages/profile/profile_page.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/auth_controller.dart';
import '../../controller/fixed_accounts_controller.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import '../cards/cards_page.dart';
import '../profile/pages/fixed_accounts_page.dart';
import 'widget/credit_card_selection.dart';

import 'widget/finance_summary.dart';

import 'widget/logout_button.dart';
import 'widget/logout_confirmation_dialog.dart';
import 'widget/setting_item.dart';
import 'widget/widghet_fixed_accoutns.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());

    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      drawer: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.h,
              ),
              SettingItem(
                icon: Iconsax.user,
                title: 'Perfil',
                onTap: () => Get.to(() => const ProfilePage()),
              ),
              _buildDivider(),
              SettingItem(
                icon: Iconsax.card,
                title: 'Meus Cartões',
                onTap: () => Get.to(() => const CardsPage()),
              ),
              _buildDivider(),
              SettingItem(
                icon: Iconsax.receipt_1,
                title: 'Minhas Contas Fixas',
                onTap: () => Get.to(() => const FixedAccountsPage()),
              ),
              Spacer(),
              LogoutButton(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => LogoutConfirmationDialog(
                    authController: authController,
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.h,
                ),
                child: Column(
                  spacing: 20.h,
                  children: [
                    FinanceSummaryWidget(),
                    DefaultWidgetFixedAccounts(),
                    CreditCardSection(),
                    ParcelamentosCard(),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1,
    );
  }
}

class ParcelamentosCard extends StatelessWidget {
  final TransactionController _transactionController = Get.find<TransactionController>();

  ParcelamentosCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          24.r,
        ),
        color: theme.cardColor,
      ),
      padding: EdgeInsets.all(12.h),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 2.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parcelamentos do Mês',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: DefaultColors.grey20,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final currentMonth = DateTime.now().month;
              final currentYear = DateTime.now().year;

              // Filtra transações que são parcelamentos (título contém "Parcela")
              final parcelamentos = _transactionController.transaction.where((t) => t.title?.contains('Parcela') ?? false).where((t) {
                if (t.paymentDay == null) return false;
                final date = DateTime.parse(t.paymentDay!);
                return date.month == currentMonth && date.year == currentYear;
              }).toList();

              if (parcelamentos.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Nenhum parcelamento este mês',
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 12.sp,
                    ),
                  ),
                );
              }

              // Calcular o valor total das parcelas
              final totalParcelasValue = parcelamentos.fold(0.0, (sum, parcela) {
                final valueString = parcela.value.replaceAll('R\$', '').trim().replaceAll('.', '').replaceAll(',', '.');
                return sum + double.parse(valueString);
              });

              return Column(
                children: [
                  ...parcelamentos.map((parcela) {
                    // Extrai informações da parcela do título
                    final regex = RegExp(r'Parcela (\d+) de (\d+): (.+)');
                    final match = regex.firstMatch(parcela.title ?? '');
                    final parcelaAtual = match?.group(1) ?? '?';
                    final totalParcelas = match?.group(2) ?? '?';
                    final tituloOriginal = match?.group(3) ?? parcela.title;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150.w,
                                child: Text(
                                  '$tituloOriginal ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: theme.primaryColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (parcela.paymentDay != null)
                                SizedBox(
                                  width: 150.w,
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(DateTime.parse(parcela.paymentDay!)),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                      color: DefaultColors.grey20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 130.w,
                                child: Text(
                                  'R\$ ${parcela.value}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: theme.primaryColor,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(
                                width: 100.w,
                                child: Text(
                                  parcela.paymentType ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11.sp,
                                    color: DefaultColors.grey20,
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  SizedBox(
                    height: 8.h,
                  ),
                  // Total das parcelas
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${totalParcelasValue.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
