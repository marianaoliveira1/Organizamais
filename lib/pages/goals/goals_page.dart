import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controller/goal_controller.dart';
import '../../model/goal_model.dart';
import '../transaction/pages/category_page.dart';
import 'pages/add_goal_page.dart';
import 'pages/details_goals_page.dart';

class GoalsPage extends StatelessWidget {
  final GoalController goalController = Get.put(GoalController());

  GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    goalController.startGoalStream();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 30.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Metas',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                InkWell(
                  onTap: () => Get.to(
                    () => AddGoalPage(),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(60.r),
                    ),
                    padding: EdgeInsets.all(6.h),
                    child: Icon(Iconsax.add, size: 16.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Atinja seus objetivos financeiros mais rápido',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (goalController.goal.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma meta encontrada.',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: goalController.goal.length,
                  itemBuilder: (context, index) {
                    final GoalModel goal = goalController.goal[index];
                    final String sanitized =
                        goal.value.replaceAll(RegExp(r'[^0-9,\.]'), '');
                    final int lastComma = sanitized.lastIndexOf(',');
                    final int lastDot = sanitized.lastIndexOf('.');
                    final int sepIndex =
                        lastComma > lastDot ? lastComma : lastDot;
                    String numeric;
                    if (sepIndex != -1) {
                      final String intPart = sanitized
                          .substring(0, sepIndex)
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      final String decPart = sanitized
                          .substring(sepIndex + 1)
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      numeric = '$intPart.$decPart';
                    } else {
                      numeric = sanitized.replaceAll(RegExp(r'[^0-9]'), '');
                    }
                    final double numericValue = double.tryParse(numeric) ?? 0.0;
                    final double progress = goal.currentValue / numericValue;
                    final category = findCategoryById(goal.categoryId);
                    final formattedDate = goal.date;
                    final String formattedCurrentValue =
                        _formatCurrencyBRL(goal.currentValue);
                    final String formattedTargetValue =
                        _formatCurrencyBRL(numericValue);

                    return InkWell(
                      onTap: () =>
                          Get.to(() => GoalDetailsPage(initialGoal: goal)),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      category != null
                                          ? Image.asset(
                                              category['icon'],
                                              height: 28.h,
                                              width: 28.w,
                                            )
                                          : Container(
                                              width: 28.w,
                                              height: 28.h,
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade800,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.category,
                                                color: Colors.white,
                                                size: 24.sp,
                                              ),
                                            ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        goal.name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "R\$ $formattedCurrentValue",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "R\$ $formattedTargetValue",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  minHeight: 6.h,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format currency in Brazilian Real standard
  String _formatCurrencyBRL(double value) {
    // Convert to string with 2 decimal places
    String stringValue = value.toStringAsFixed(2);

    // Replace dot with comma for decimal separator
    stringValue = stringValue.replaceAll('.', ',');

    // Add thousand separators
    List<String> parts = stringValue.split(',');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    // Add thousands separator (.) for values over 999
    if (integerPart.length > 3) {
      String result = '';
      int count = 0;

      for (int i = integerPart.length - 1; i >= 0; i--) {
        result = integerPart[i] + result;
        count++;

        if (count % 3 == 0 && i > 0) {
          result = '.$result';
        }
      }

      integerPart = result;
    }

    return "$integerPart,$decimalPart";
  }
}
