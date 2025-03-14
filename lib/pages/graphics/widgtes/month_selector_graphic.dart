// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../graphics_page.dart';

class MonthSelectorGraphic extends StatelessWidget {
  final RxString selectedMonth;
  final RxnInt selectedCategoryId;
  final ThemeData theme;

  const MonthSelectorGraphic({
    super.key,
    required this.selectedMonth,
    required this.selectedCategoryId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: getAllMonths().length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final month = getAllMonths()[index];
          return Obx(
            () => GestureDetector(
              onTap: () {
                selectedMonth.value = selectedMonth.value == month ? '' : month;
                selectedCategoryId.value = null;
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: selectedMonth.value == month
                        ? DefaultColors.green
                        : DefaultColors.grey.withOpacity(
                            0.3,
                          ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  month,
                  style: TextStyle(
                    color: selectedMonth.value == month ? theme.primaryColor : DefaultColors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
