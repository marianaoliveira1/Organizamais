import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/page/transaction/pages/%20%20category.dart';
import 'package:organizamais/utils/color.dart';

import '../../../model/fixed_account_model.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
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
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            categories_expenses.firstWhere((element) => element['id'] == fixedAccount.category)['icon'],
                            width: 26.w,
                            height: 26.h,
                          ),
                          SizedBox(width: 20.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fixedAccount.title,
                                style: TextStyle(
                                  color: DefaultColors.black,
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
                            "R\$ ${fixedAccount.value}",
                            style: TextStyle(
                              color: DefaultColors.black,
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
                color: DefaultColors.black,
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
