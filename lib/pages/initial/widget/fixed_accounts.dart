// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  String _calculateTotal() {
    double total = 0;
    for (var account in fixedAccounts) {
      String valueString = account.value.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.');
      total += double.tryParse(valueString) ?? 0;
    }

    return total.toStringAsFixed(2).replaceAll('.', ',');
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
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text(
                    "Nenhuma conta fixa cadastrada",
                    style: TextStyle(
                      color: DefaultColors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fixedAccounts.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 14.h,
                ),
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
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
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
                          () => FixedAccountsPage(
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
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DefaultColors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50.r),
                                  ),
                                  child: Image.asset(
                                    categories_expenses.firstWhere((element) => element['id'] == fixedAccount.category)['icon'],
                                    width: 30.w,
                                    height: 30.h,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fixedAccount.title,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
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
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  fixedAccount.value,
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
          SizedBox(
            height: 12.h,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Text(
              "R\$ ${_calculateTotal()}",
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
