// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import '../pages/fixed_accotuns_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FixedAccounts extends StatelessWidget {
  const FixedAccounts({
    super.key,
  });

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

  String _buildPaymentScheduleText(fixedAccount) {
    String baseText;
    final String? frequency = fixedAccount.frequency;

    if (frequency == 'quinzenal' &&
        fixedAccount.biweeklyDays != null &&
        fixedAccount.biweeklyDays.length >= 2) {
      baseText =
          "Dias ${fixedAccount.biweeklyDays[0]} e ${fixedAccount.biweeklyDays[1]} de cada mês";
    } else if (frequency == 'semanal' && fixedAccount.weeklyWeekday != null) {
      const weekdays = [
        '',
        'Segunda-feira',
        'Terça-feira',
        'Quarta-feira',
        'Quinta-feira',
        'Sexta-feira',
        'Sábado',
        'Domingo'
      ];
      final weekdayName = weekdays[fixedAccount.weeklyWeekday];
      baseText = "Toda ${weekdayName}";
    } else if (frequency == 'bimestral') {
      baseText = "Dia ${fixedAccount.paymentDay} a cada 2 meses";
    } else if (frequency == 'trimestral') {
      baseText = "Dia ${fixedAccount.paymentDay} a cada 3 meses";
    } else {
      baseText = "Dia ${fixedAccount.paymentDay} de cada mês";
    }

    if (fixedAccount.startMonth != null && fixedAccount.startYear != null) {
      List<String> monthNames = [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro'
      ];

      String monthName = monthNames[fixedAccount.startMonth! - 1];
      baseText += " \n(desde $monthName/${fixedAccount.startYear})";
    }

    return baseText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fixedAccountsController = Get.find<FixedAccountsController>();

    return Container(
      // padding: EdgeInsets.only(right: 6.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () {
              final currentFixedAccounts =
                  fixedAccountsController.fixedAccounts;

              if (currentFixedAccounts.isEmpty) {
                return Center(
                  child: Text(
                    "Nenhuma conta fixa cadastrada",
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentFixedAccounts.length,
                itemBuilder: (context, index) {
                  final fixedAccount = currentFixedAccounts[index];
                  final isDeactivated = fixedAccountsController
                      .isAccountDeactivated(fixedAccount);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Opacity(
                      opacity: isDeactivated ? 0.6 : 1.0,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24.r),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: Slidable(
                            key: ValueKey(
                                'fixed-${fixedAccount.id ?? fixedAccount.title}'),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.60,
                              children: [
                                CustomSlidableAction(
                                  onPressed: (_) {
                                    if (!isDeactivated) {
                                      Get.to(
                                        () => AddFixedAccountsFormPage(
                                          fixedAccount: fixedAccount,
                                          onSave: (fa) =>
                                              fixedAccountsController
                                                  .updateFixedAccount(fa),
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: Colors.orange,
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      'Editar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10.sp,
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                CustomSlidableAction(
                                  onPressed: (_) async {
                                    // Reutiliza o mesmo AlertDialog detalhado já implementado no onLongPress
                                    await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          _buildFixedAccountDialog(
                                        context,
                                        theme,
                                        fixedAccountsController,
                                        fixedAccount,
                                        isDeactivated,
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      'Deletar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10.sp,
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            child: InkWell(
                              child: Container(
                                // Reserva espaço à direita para as ações do Slidable
                                // 0.60 de extentRatio = 60% da largura da tela
                                // Aplicamos um padding equivalente para evitar sobreposição
                                padding: EdgeInsets.only(
                                  // left: 16.w,
                                  // top: 12.h,
                                  // bottom: 12.h,
                                  right: MediaQuery.of(context).size.width *
                                      0.01, // Reserva 5% para margin de segurança
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.h),
                                            decoration: BoxDecoration(
                                              color: isDeactivated
                                                  ? DefaultColors.grey
                                                      .withOpacity(0.3)
                                                  : DefaultColors.grey
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(50.r),
                                            ),
                                            child: Image.asset(
                                              categories_expenses.firstWhere(
                                                  (element) =>
                                                      element['id'] ==
                                                      fixedAccount
                                                          .category)['icon'],
                                              width: 19.w,
                                              height: 19.h,
                                              color: isDeactivated
                                                  ? DefaultColors.grey
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        fixedAccount.title,
                                                        style: TextStyle(
                                                            color: isDeactivated
                                                                ? DefaultColors
                                                                    .grey
                                                                : theme
                                                                    .primaryColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12.sp,
                                                            decoration: isDeactivated
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : TextDecoration
                                                                    .none),
                                                        maxLines: 2,
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (isDeactivated)
                                                      SizedBox(width: 6.w),
                                                    if (isDeactivated)
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 6.w,
                                                                vertical: 2.h),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.r),
                                                          border: Border.all(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1),
                                                        ),
                                                        child: Text(
                                                          'DESATIVADA',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 8.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Text(
                                                  fixedAccount.deactivatedAt !=
                                                          null
                                                      ? "Desativada em ${fixedAccount.deactivatedAt != null ? '${fixedAccount.deactivatedAt!.day}/${fixedAccount.deactivatedAt!.month}/${fixedAccount.deactivatedAt!.year}' : ''}"
                                                      : _buildPaymentScheduleText(
                                                          fixedAccount),
                                                  style: TextStyle(
                                                    color: DefaultColors.grey20,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Espaçamento para garantir que o valor não fique muito colado no conteúdo
                                    SizedBox(width: 8.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatCurrency(fixedAccount.value),
                                          style: TextStyle(
                                            color: isDeactivated
                                                ? DefaultColors.grey
                                                : theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                            decoration: isDeactivated
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100
                                              .w, // Reduzido para dar mais espaço
                                          child: Text(
                                            "${fixedAccount.paymentType}",
                                            style: TextStyle(
                                              color: DefaultColors.grey20,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.end,
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Obx(() {
            final currentFixedAccounts = fixedAccountsController.fixedAccounts;
            final activeAccounts = currentFixedAccounts
                .where((account) =>
                    !fixedAccountsController.isAccountDeactivated(account))
                .toList();
            // final deactivatedAccounts = currentFixedAccounts
            //     .where((account) =>
            //         fixedAccountsController.isAccountDeactivated(account))
            //     .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (activeAccounts.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h, right: 10.h),
                    child: Text(
                      _formatCurrency(
                        activeAccounts.fold(0.0, (total, account) {
                          String cleanValue =
                              account.value.replaceAll('R\$', '').trim();
                          if (cleanValue.contains('.') &&
                              cleanValue.contains(',')) {
                            cleanValue = cleanValue
                                .replaceAll('.', '')
                                .replaceAll(',', '.');
                          } else if (cleanValue.contains(',')) {
                            cleanValue = cleanValue.replaceAll(',', '.');
                          }
                          return total + (double.tryParse(cleanValue) ?? 0);
                        }).toString(),
                      ),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                // if (deactivatedAccounts.isNotEmpty)
                //   Padding(
                //     padding: EdgeInsets.only(top: 4.h, right: 10.h),
                //     child: Text(
                //       "${deactivatedAccounts.length} conta${deactivatedAccounts.length > 1 ? 's' : ''} desativada${deactivatedAccounts.length > 1 ? 's' : ''}",
                //       style: TextStyle(
                //         color: DefaultColors.grey,
                //         fontWeight: FontWeight.w400,
                //         fontSize: 9.sp,
                //         fontStyle: FontStyle.italic,
                //       ),
                //     ),
                //   ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Helper para abrir o mesmo AlertDialog usado no onLongPress
  Widget _buildFixedAccountDialog(
    BuildContext context,
    ThemeData theme,
    FixedAccountsController fixedAccountsController,
    dynamic fixedAccount,
    bool isDeactivated,
  ) {
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
              if (isDeactivated) ...[
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
                          Icon(Icons.info_outline,
                              color: Colors.orange, size: 16.sp),
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
              ] else ...[
                Text(
                  'Como deseja remover a conta fixa "${fixedAccount.title}"?',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.pause_circle_outline,
                          color: Colors.orange, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Desabilitar: A conta não aparecerá nos próximos meses, mas será mantida no histórico',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.delete_forever,
                          color: Colors.red, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Excluir permanentemente: A conta será removida completamente',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
            if (!isDeactivated)
              TextButton(
                onPressed: () async {
                  await fixedAccountsController
                      .disableFixedAccount(fixedAccount.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.pause_circle_outline,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text('Conta "${fixedAccount.title}" desabilitada'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: Text(
                  'Desabilitar',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            TextButton(
              onPressed: () async {
                await fixedAccountsController
                    .deleteFixedAccount(fixedAccount.id!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.delete_forever,
                            color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                            'Conta "${fixedAccount.title}" excluída permanentemente'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Text(
                'Excluir',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
