// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/fixed_accounts_controller.dart';
import '../../../model/fixed_account_model.dart';
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
    final List<FixedAccountModel> fixedAccounts =
        fixedAccountsController.fixedAccounts;

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
                  Obx(
                    () {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fixedAccounts.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 14.h),
                        itemBuilder: (context, index) {
                          final fixedAccount = fixedAccounts[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.h),
                                      decoration: BoxDecoration(
                                        color:
                                            DefaultColors.grey.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(50.r),
                                      ),
                                      child: Image.asset(
                                        categories_expenses.firstWhere(
                                            (element) =>
                                                element['id'] ==
                                                fixedAccount.category)['icon'],
                                        width: 28.w,
                                        height: 28.h,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 130.w,
                                          child: Text(
                                            fixedAccount.title,
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                            softWrap: true,
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
                                  SizedBox(
                                    width: 100.w,
                                    child: Text(
                                      "${fixedAccount.paymentType}",
                                      style: TextStyle(
                                        color: DefaultColors.grey,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.end,
                                      softWrap: true,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
