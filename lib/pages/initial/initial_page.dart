import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/profile/profile_page.dart';

import '../../controller/auth_controller.dart';
import '../../controller/fixed_accounts_controller.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import '../../utils/color.dart';
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
                    InstallmentsWidget(),
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

class InstallmentsWidget extends StatelessWidget {
  final TransactionController _transactionController = Get.find<TransactionController>();

  InstallmentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
      ),
      child: Obx(() {
        // 1. Filtra apenas transações parceladas
        final installments = _transactionController.transaction.where((t) => t.title?.contains('Parcela') ?? false).toList();

        // 2. Agrupa por título base (identificando a transação original)
        final Map<String, List<TransactionModel>> groupedInstallments = {};

        for (final installment in installments) {
          final title = installment.title ?? '';
          // Extrai o título base (removendo "Parcela X/Y: ")
          final baseTitle = title.replaceAll(RegExp(r'Parcela \d+\/\d+: '), '');

          if (!groupedInstallments.containsKey(baseTitle)) {
            groupedInstallments[baseTitle] = [];
          }
          groupedInstallments[baseTitle]!.add(installment);
        }

        // 3. Processa cada grupo de parcelas
        final currentMonth = DateTime.now().month;
        final currentYear = DateTime.now().year;

        final List<Widget> installmentCards = [];

        groupedInstallments.forEach((baseTitle, allInstallments) {
          // Ordena as parcelas pela data de pagamento
          allInstallments.sort((a, b) {
            final dateA = DateTime.parse(a.paymentDay ?? '');
            final dateB = DateTime.parse(b.paymentDay ?? '');
            return dateA.compareTo(dateB);
          });

          // Encontra a parcela atual (do mês vigente)
          TransactionModel? currentInstallment;
          int currentIndex = 0;
          int totalInstallments = allInstallments.length;

          for (int i = 0; i < allInstallments.length; i++) {
            final date = DateTime.parse(allInstallments[i].paymentDay ?? '');
            if (date.month == currentMonth && date.year == currentYear) {
              currentInstallment = allInstallments[i];
              currentIndex = i + 1; // +1 porque começa em 1, não em 0
              break;
            }
          }

          // Se encontrou uma parcela deste mês, adiciona ao widget
          if (currentInstallment != null) {
            installmentCards.add(
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 8.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150.w,
                      child: Text(
                        baseTitle,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 100.w,
                      child: Text(
                        'R\$ ${currentInstallment.value}',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });

        if (installmentCards.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parcelas deste mês',
              style: TextStyle(
                color: DefaultColors.grey20,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            ...installmentCards,
          ],
        );
      }),
    );
  }
}
