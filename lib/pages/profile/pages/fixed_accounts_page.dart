// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/fixed_accounts_controller.dart';
import '../../../utils/color.dart';
import '../../../model/fixed_account_model.dart';
import '../../transaction/pages/category_page.dart';

class FixedAccountsPage extends StatelessWidget {
  const FixedAccountsPage({super.key});

  String _formatCurrency(String value) {
    // Remove 'R$' and replace comma with dot for decimal
    String cleanValue = value.replaceAll('R\$', '').trim();

    // If the value uses '.' as thousand separator and ',' as decimal
    if (cleanValue.contains('.') && cleanValue.contains(',')) {
      // Remove thousand separator
      cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
    }
    // If the value uses ',' as decimal separator
    else if (cleanValue.contains(',')) {
      cleanValue = cleanValue.replaceAll(',', '.');
    }

    // Parse the clean value
    double parsedValue = double.tryParse(cleanValue) ?? 0;

    // Use NumberFormat to format as Brazilian Real
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    return formatter.format(parsedValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    FixedAccountsController fixedAccountsController =
        Get.find<FixedAccountsController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Minhas contas fixas",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 18.h),
              _buildHeroCard(theme, fixedAccountsController),
              SizedBox(height: 20.h),
              Text(
                'Suas contas fixas',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () {
                  final fixedAccounts =
                      fixedAccountsController.fixedAccountsWithDeactivated;
                  if (fixedAccounts.isEmpty) {
                    return _buildEmptyState(theme);
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fixedAccounts.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final fixedAccount = fixedAccounts[index];
                      final isDeactivated = fixedAccountsController
                          .isAccountDeactivated(fixedAccount);

                      return _buildFixedAccountTile(
                        context: context,
                        theme: theme,
                        controller: fixedAccountsController,
                        fixedAccount: fixedAccount,
                        isDeactivated: isDeactivated,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    ThemeData theme,
    FixedAccountsController controller,
  ) {
    return Obx(() {
      final accounts = controller.fixedAccountsWithDeactivated;
      final active =
          accounts.where((a) => !controller.isAccountDeactivated(a)).length;
      final paused = accounts.length - active;
      final total = accounts.length;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.cardColor.withOpacity(0.95),
              theme.cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre suas contas',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.primaryColor.withOpacity(0.85),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Acompanhe suas contas fixas e veja rapidamente o que está ativo, pausado e o total do mês',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _HeroStatPill(
                  label: 'Ativas',
                  value: active,
                  highlight: true,
                ),
                SizedBox(width: 10.w),
                _HeroStatPill(
                  label: 'Pausadas',
                  value: paused,
                  highlight: false,
                ),
                SizedBox(width: 10.w),
                _HeroStatPill(
                  label: 'Total',
                  value: total,
                  highlight: false,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_repeat_outlined,
              color: theme.primaryColor,
              size: 26.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Nenhuma conta fixa encontrada',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Crie contas para automatizar projeções e alertas mensais.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.primaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedAccountTile({
    required BuildContext context,
    required ThemeData theme,
    required FixedAccountsController controller,
    required FixedAccountModel fixedAccount,
    required bool isDeactivated,
  }) {
    final categoryData = _categoryDataFor(fixedAccount.category);
    final Color categoryColor =
        (categoryData?['color'] as Color?) ?? theme.primaryColor;
    final String? categoryIconPath = categoryData?['icon'] as String?;

    return Opacity(
      opacity: isDeactivated ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onLongPress: () => _showAccountOptions(
            context: context,
            theme: theme,
            controller: controller,
            fixedAccount: fixedAccount,
            isDeactivated: isDeactivated,
          ),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // width: 48.w,
                  // height: 48.w,
                  // decoration: BoxDecoration(
                  //   color: isDeactivated
                  //       ? DefaultColors.grey.withOpacity(0.18)
                  //       : categoryColor.withOpacity(0.22),
                  //   borderRadius: BorderRadius.circular(16.r),
                  // ),
                  child: categoryIconPath != null
                      ? Image.asset(
                          categoryIconPath,
                          width: 40.w,
                          height: 40.w,
                          color: isDeactivated ? DefaultColors.grey : null,
                        )
                      : Icon(
                          Icons.category_outlined,
                          color: isDeactivated
                              ? DefaultColors.grey
                              : categoryColor,
                          size: 22.sp,
                        ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fixedAccount.title,
                              style: TextStyle(
                                color: isDeactivated
                                    ? DefaultColors.grey
                                    : theme.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                decoration: isDeactivated
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                              maxLines: 2,
                              softWrap: true,
                            ),
                          ),
                          if (isDeactivated)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                'DESATIVADA',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        isDeactivated
                            ? "Desativada em ${fixedAccount.deactivatedAt != null ? '${fixedAccount.deactivatedAt!.day.toString().padLeft(2, '0')}/${fixedAccount.deactivatedAt!.month.toString().padLeft(2, '0')}/${fixedAccount.deactivatedAt!.year}' : ''}"
                            : "Dia ${fixedAccount.paymentDay} de cada mês",
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(fixedAccount.value),
                      style: TextStyle(
                        color: isDeactivated
                            ? DefaultColors.grey
                            : theme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        decoration: isDeactivated
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fixedAccount.paymentType ?? 'Ver detalhes',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
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

  void _showAccountOptions({
    required BuildContext context,
    required ThemeData theme,
    required FixedAccountsController controller,
    required FixedAccountModel fixedAccount,
    required bool isDeactivated,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: Row(
                children: [
                  Icon(
                    isDeactivated
                        ? Icons.pause_circle
                        : Icons.remove_circle_outline,
                    color: isDeactivated ? Colors.orange : theme.primaryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isDeactivated ? 'Conta Desativada' : 'Remover Conta Fixa',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDeactivated)
                    _buildDeactivatedInfo(theme, fixedAccount)
                  else
                    _buildRemovalInfo(theme, fixedAccount),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                if (isDeactivated)
                  TextButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            setState(() => isProcessing = true);
                            await controller
                                .reactivateFixedAccount(fixedAccount.id!);
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.refresh,
                                        color: Colors.white, size: 20.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                        'Conta "${fixedAccount.title}" reativada'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                    child: isProcessing
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh,
                                  size: 16.sp, color: Colors.green),
                              SizedBox(width: 4.w),
                              Text(
                                'Reativar',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                if (!isDeactivated)
                  TextButton(
                    child: Text(
                      'Desabilitar',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      controller.disableFixedAccount(fixedAccount.id!);
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                TextButton(
                  child: Text(
                    'Excluir',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    controller.deleteFixedAccount(fixedAccount.id!);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeactivatedInfo(
      ThemeData theme, FixedAccountModel fixedAccount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Detalhes da Desativação',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conta: ${fixedAccount.title}',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Valor: ${_formatCurrency(fixedAccount.value)}',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Desativada em: ${fixedAccount.deactivatedAt != null ? '${fixedAccount.deactivatedAt!.day.toString().padLeft(2, '0')}/${fixedAccount.deactivatedAt!.month.toString().padLeft(2, '0')}/${fixedAccount.deactivatedAt!.year}' : ''}',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (fixedAccount.deactivatedAt != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Tempo desativada: ${DateTime.now().difference(fixedAccount.deactivatedAt!).inDays} dias',
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Esta conta está desativada e não aparece nos próximos meses. Você pode reativá-la ou excluí-la permanentemente.',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildRemovalInfo(ThemeData theme, FixedAccountModel fixedAccount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como deseja remover a conta fixa "${fixedAccount.title}"?',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '• Desabilitar: A conta não aparecerá nos próximos meses, mas será mantida no histórico',
          style: TextStyle(
            color: DefaultColors.grey,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '• Excluir permanentemente: A conta será removida completamente',
          style: TextStyle(
            color: DefaultColors.grey,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic>? _categoryDataFor(int id) {
    for (final category in categories_expenses) {
      final categoryId = category['id'] as int?;
      if (categoryId == id) return category;
    }
    return null;
  }
}

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final int value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: highlight
              ? theme.scaffoldBackgroundColor
              : theme.scaffoldBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: DefaultColors.grey20.withOpacity(highlight ? 0.25 : 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: highlight ? theme.primaryColor : theme.primaryColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: highlight ? theme.primaryColor : theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
