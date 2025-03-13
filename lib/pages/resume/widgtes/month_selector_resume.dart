import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import 'resume_content.dart';

class MonthSelectorResume extends StatelessWidget {
  final RxString selectedMonth;

  const MonthSelectorResume({
    super.key,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ResumeContent.getAllMonths().length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) => _buildMonthItem(context, ResumeContent.getAllMonths()[index]),
      ),
    );
  }

  Widget _buildMonthItem(BuildContext context, String month) {
    return Obx(
      () => GestureDetector(
        onTap: () => selectedMonth.value = selectedMonth.value == month ? '' : month,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selectedMonth.value == month ? DefaultColors.green : DefaultColors.grey.withOpacity(0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            month,
            style: TextStyle(
              color: selectedMonth.value == month ? Theme.of(context).primaryColor : DefaultColors.grey,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
