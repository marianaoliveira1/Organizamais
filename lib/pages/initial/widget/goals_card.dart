import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizamais/utils/color.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../../goals/pages/add_goal_page.dart';
import '../../goals/pages/details_goals_page.dart';
import '../../transaction/pages/category_page.dart';

class GoalsCard extends StatelessWidget {
  const GoalsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final GoalController goalController = Get.find<GoalController>();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas metas financeiras',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              InkWell(
                onTap: () => Get.to(() => const AddGoalPage()),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(60.r),
                  ),
                  padding: EdgeInsets.all(6.h),
                  child:
                      Icon(Iconsax.add, size: 16.sp, color: theme.primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final goals = goalController.goal;
            if (goals.isEmpty) {
              return Text(
                'Crie sua primeira meta clicando no +',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: DefaultColors.grey,
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final GoalModel goal = goals[index];
                final String sanitized =
                    goal.value.replaceAll(RegExp(r'[^0-9,\.]'), '');
                final int lastComma = sanitized.lastIndexOf(',');
                final int lastDot = sanitized.lastIndexOf('.');
                final int sepIndex = lastComma > lastDot ? lastComma : lastDot;
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
                final double target = double.tryParse(numeric) ?? 0.0;
                final double progress = target > 0
                    ? (goal.currentValue / target).clamp(0.0, 1.0)
                    : 0.0;
                final category = findCategoryById(goal.categoryId);

                return InkWell(
                  onTap: () => Get.to(() => GoalDetailsPage(initialGoal: goal)),
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (category != null)
                                  Image.asset(
                                    category['icon'],
                                    width: 24.w,
                                    height: 24.w,
                                  )
                                else
                                  Icon(Icons.category,
                                      size: 18.sp, color: theme.primaryColor),
                                SizedBox(width: 8.w),
                                Text(
                                  goal.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              goal.date,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double barWidth = constraints.maxWidth;
                            final double clamped = progress.clamp(0.0, 1.0);
                            final double markerLeft = (barWidth * clamped - 20)
                                .clamp(0, barWidth - 40);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: LinearProgressIndicator(
                                    value: clamped,
                                    backgroundColor:
                                        theme.primaryColor.withOpacity(0.08),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        DefaultColors.green),
                                    minHeight: 8.h,
                                  ),
                                ),
                                Positioned(
                                  left: markerLeft,
                                  top: -22.h,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: Text(
                                          '${(clamped * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Container(
                                        width: 2.w,
                                        height: 10.h,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              NumberFormat.currency(
                                      locale: 'pt_BR', symbol: 'R\$')
                                  .format(goal.currentValue),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                      locale: 'pt_BR', symbol: 'R\$')
                                  .format(target),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
