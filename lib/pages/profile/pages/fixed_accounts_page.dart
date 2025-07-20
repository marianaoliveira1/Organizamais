// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/fixed_accounts_controller.dart';
import '../../../utils/color.dart';
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
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
          horizontal: 16.w,
        ),
        child: Column(
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 10.h,
                horizontal: 16.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    child: Obx(
                      () {
                        final fixedAccounts = fixedAccountsController
                            .fixedAccountsWithDeactivated;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: fixedAccounts.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 14.h),
                          itemBuilder: (context, index) {
                            final fixedAccount = fixedAccounts[index];
                            final isDeactivated = fixedAccountsController
                                .isAccountDeactivated(fixedAccount);

                            return Opacity(
                              opacity: isDeactivated ? 0.6 : 1.0,
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12.r),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12.r),
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                          builder: (context, setState) {
                                        bool isProcessing = false;

                                        return AlertDialog(
                                          backgroundColor: theme.cardColor,
                                          title: Row(
                                            children: [
                                              Icon(
                                                isDeactivated
                                                    ? Icons.pause_circle
                                                    : Icons
                                                        .remove_circle_outline,
                                                color: isDeactivated
                                                    ? Colors.orange
                                                    : theme.primaryColor,
                                                size: 20.sp,
                                              ),
                                              SizedBox(width: 8.w),
                                              Expanded(
                                                child: Text(
                                                  isDeactivated
                                                      ? 'Conta Desativada'
                                                      : 'Remover Conta Fixa',
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (isDeactivated) ...[
                                                Container(
                                                  padding: EdgeInsets.all(12.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r),
                                                    border: Border.all(
                                                        color: Colors.orange
                                                            .withOpacity(0.3)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .info_outline,
                                                              color:
                                                                  Colors.orange,
                                                              size: 16.sp),
                                                          SizedBox(width: 8.w),
                                                          Expanded(
                                                            child: Text(
                                                              'Detalhes da Desativação',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .orange
                                                                    .shade700,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8.h),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            EdgeInsets.all(8.h),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: theme
                                                              .scaffoldBackgroundColor
                                                              .withOpacity(0.3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.r),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Conta: ${fixedAccount.title}',
                                                              style: TextStyle(
                                                                color: theme
                                                                    .primaryColor,
                                                                fontSize: 11.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 4.h),
                                                            Text(
                                                              'Valor: ${_formatCurrency(fixedAccount.value)}',
                                                              style: TextStyle(
                                                                color: theme
                                                                    .primaryColor,
                                                                fontSize: 11.sp,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 4.h),
                                                            Text(
                                                              'Desativada em: ${fixedAccount.deactivatedAt != null ? '${fixedAccount.deactivatedAt!.day.toString().padLeft(2, '0')}/${fixedAccount.deactivatedAt!.month.toString().padLeft(2, '0')}/${fixedAccount.deactivatedAt!.year}' : ''}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .orange
                                                                    .shade700,
                                                                fontSize: 11.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            if (fixedAccount
                                                                    .deactivatedAt !=
                                                                null) ...[
                                                              SizedBox(
                                                                  height: 4.h),
                                                              Text(
                                                                'Tempo desativada: ${DateTime.now().difference(fixedAccount.deactivatedAt!).inDays} dias',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      DefaultColors
                                                                          .grey,
                                                                  fontSize:
                                                                      10.sp,
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
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            if (isDeactivated)
                                              TextButton(
                                                onPressed: isProcessing
                                                    ? null
                                                    : () async {
                                                        setState(() =>
                                                            isProcessing =
                                                                true);
                                                        await fixedAccountsController
                                                            .reactivateFixedAccount(
                                                                fixedAccount
                                                                    .id!);
                                                        Navigator.of(context)
                                                            .pop();
                                                        // Show success feedback
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .refresh,
                                                                    color: Colors
                                                                        .white,
                                                                    size:
                                                                        20.sp),
                                                                SizedBox(
                                                                    width: 8.w),
                                                                Text(
                                                                    'Conta "${fixedAccount.title}" reativada'),
                                                              ],
                                                            ),
                                                            backgroundColor:
                                                                Colors.green,
                                                            duration: Duration(
                                                                seconds: 3),
                                                          ),
                                                        );
                                                      },
                                                child: isProcessing
                                                    ? SizedBox(
                                                        width: 16.w,
                                                        height: 16.h,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.green),
                                                        ),
                                                      )
                                                    : Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.refresh,
                                                              size: 16.sp,
                                                              color:
                                                                  Colors.green),
                                                          SizedBox(width: 4.w),
                                                          Text(
                                                            'Reativar',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
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
                                                  fixedAccountsController
                                                      .disableFixedAccount(
                                                          fixedAccount.id!);
                                                  Navigator.of(context).pop();
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
                                                fixedAccountsController
                                                    .deleteFixedAccount(
                                                        fixedAccount.id!);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      }),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.h, horizontal: 4.w),
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
                                                      BorderRadius.circular(
                                                          50.r),
                                                ),
                                                child: Image.asset(
                                                  categories_expenses
                                                      .firstWhere((element) =>
                                                          element['id'] ==
                                                          fixedAccount
                                                              .category)['icon'],
                                                  width: 24.w,
                                                  height: 24.h,
                                                  color: isDeactivated
                                                      ? DefaultColors.grey
                                                      : null,
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
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
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12.sp,
                                                              decoration: isDeactivated
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : TextDecoration
                                                                      .none,
                                                            ),
                                                            maxLines: 2,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                        if (isDeactivated)
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8.w,
                                                                    vertical:
                                                                        3.h),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.r),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .withOpacity(
                                                                          0.3),
                                                                  width: 1),
                                                            ),
                                                            child: Text(
                                                              'DESATIVADA',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 9.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Text(
                                                      isDeactivated
                                                          ? "Desativada em ${fixedAccount.deactivatedAt != null ? '${fixedAccount.deactivatedAt!.day}/${fixedAccount.deactivatedAt!.month}/${fixedAccount.deactivatedAt!.year}' : ''}"
                                                          : "Dia ${fixedAccount.paymentDay} de cada mês",
                                                      style: TextStyle(
                                                        color:
                                                            DefaultColors.grey,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              _formatCurrency(
                                                  fixedAccount.value),
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
                                              width: 100.w,
                                              child: Text(
                                                "${fixedAccount.paymentType}",
                                                style: TextStyle(
                                                  color: DefaultColors.grey,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                textAlign: TextAlign.end,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
