import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/fixed_accounts_controller.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import '../../../model/fixed_account_model.dart';
import '../pages/fixed_accotuns_page.dart';

class FixedAccounts extends StatelessWidget {
  final List<FixedAccountModel> fixedAccounts;

  const FixedAccounts({
    super.key,
    required this.fixedAccounts,
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
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    return formatter.format(parsedValue);
  }

  double _calculateTotalNumeric() {
    return fixedAccounts.fold(0.0, (total, account) {
      // Use the same cleaning logic as in _formatCurrency
      String cleanValue = account.value.replaceAll('R\$', '').trim();

      if (cleanValue.contains('.') && cleanValue.contains(',')) {
        cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
      } else if (cleanValue.contains(',')) {
        cleanValue = cleanValue.replaceAll(',', '.');
      }

      return total + (double.tryParse(cleanValue) ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    FixedAccountsController fixedAccountsController = Get.find<FixedAccountsController>();

    return Container(
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
              if (fixedAccounts.isEmpty) {
                return Center(
                  child: Text(
                    "Nenhuma conta fixa cadastrada",
                    style: TextStyle(
                      color: DefaultColors.grey20,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fixedAccounts.length,
                separatorBuilder: (context, index) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final fixedAccount = fixedAccounts[index];
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24.r),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmar exclusão'),
                            content: Text('Tem certeza que deseja excluir o cartão ${fixedAccount.title}?'),
                            actions: [
                              TextButton(
                                child: Text('Cancelar'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text('Excluir'),
                                onPressed: () {
                                  fixedAccountsController.deleteFixedAccount(fixedAccount.id!);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: () {
                        Get.to(
                          () => AddFixedAccountsFormPage(
                            fixedAccount: fixedAccount,
                            onSave: (fixedAccount) => fixedAccountsController.updateFixedAccount(
                              fixedAccount,
                            ),
                          ),
                        );
                      },
                      child: Ink(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.h),
                                    decoration: BoxDecoration(
                                      color: DefaultColors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50.r),
                                    ),
                                    child: Image.asset(
                                      categories_expenses.firstWhere((element) => element['id'] == fixedAccount.category)['icon'],
                                      width: 28.w,
                                      height: 28.h,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fixedAccount.title,
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                          softWrap: true,
                                        ),
                                        Text(
                                          "Dia ${fixedAccount.paymentDay} de cada mês",
                                          style: TextStyle(
                                            color: DefaultColors.grey,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(fixedAccount.value),
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  "${fixedAccount.paymentType}",
                                  style: TextStyle(
                                    color: DefaultColors.grey,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 12.h),
          fixedAccounts.isEmpty
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(top: 10.h, right: 10.h),
                  child: Text(
                    _formatCurrency(
                      _calculateTotalNumeric().toString(),
                    ),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
