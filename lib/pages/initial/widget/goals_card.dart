import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/pages/initial/widget/title_card.dart';
import 'package:organizamais/utils/color.dart';

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
          DefaultTitleCard(
            text: "Minhas metas financeira",
            onTap: () {
              Get.to(() => const AddGoalPage());
            },
          ),
          SizedBox(
            height: 10.h,
          ),
          Obx(() {
            final goals = goalController.goal;
            if (goals.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Nenhuma meta adicionada',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: DefaultColors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    OutlinedButton.icon(
                      onPressed: () => Get.to(() => const AddGoalPage()),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar meta'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        side: BorderSide(
                            color: theme.primaryColor.withOpacity(0.4)),
                        foregroundColor: theme.primaryColor,
                      ),
                    )
                  ],
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
                // Removido cálculo de dias por não ser utilizado no novo layout
                // Variáveis de status não utilizadas foram removidas para limpar o linter
                // Progresso formatado
                final double clamped = progress.clamp(0.0, 1.0);
                final int percent = (clamped * 100).round();
                final Color progressColor = DefaultColors.greenDark;

                return InkWell(
                  onTap: () => Get.to(() => GoalDetailsPage(initialGoal: goal)),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: category != null
                                  ? Image.asset(
                                      category['icon'],
                                      width: 26.w,
                                      height: 26.w,
                                    )
                                  : Icon(
                                      Icons.savings_outlined,
                                      size: 16.sp,
                                      color: DefaultColors.grey,
                                    ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.name,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    goal.date,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: DefaultColors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.north_east,
                                size: 14.sp,
                                color: theme.primaryColor,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 26.h),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double barWidth = constraints.maxWidth;
                            final double markerLeft = (barWidth * clamped - 20)
                                .clamp(0, barWidth - 40);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999.r),
                                  child: LinearProgressIndicator(
                                    value: clamped,
                                    minHeight: 8.h,
                                    backgroundColor:
                                        theme.primaryColor.withOpacity(0.08),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        progressColor),
                                  ),
                                ),
                                Positioned(
                                  left: markerLeft,
                                  top: -26.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius:
                                          BorderRadius.circular(999.r),
                                    ),
                                    child: Text(
                                      '$percent%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              NumberFormat.currency(
                                      locale: 'pt_BR', symbol: 'R\$')
                                  .format(goal.currentValue),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                      locale: 'pt_BR', symbol: 'R\$')
                                  .format(target),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
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
