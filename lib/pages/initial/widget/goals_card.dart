import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:organizamais/pages/initial/widget/title_card.dart';
import 'package:organizamais/widgetes/info_card.dart';
import 'package:organizamais/utils/color.dart';

import 'package:intl/intl.dart';

import '../../../controller/goal_controller.dart';
import '../../../model/goal_model.dart';
import '../pages/add_goal_page.dart';
import '../pages/details_goals_page.dart';
import '../../transaction/pages/category_page.dart';

class GoalsCard extends StatelessWidget {
  const GoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final GoalController goalController = Get.find<GoalController>();

    return Obx(() {
      final count = goalController.goal.length;
      return InfoCard(
        title: 'Minhas metas financeira ($count)',
        icon: Icons.add,
        onTap: () {
          Get.to(() => const AddGoalPage());
        },
        content: Obx(() {
          final isTablet = MediaQuery.of(context).size.width >= 600;
          final goals = goalController.goal;
          if (goals.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  'Nenhuma meta financeira adicionada',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DefaultColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
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
              final double nameFont = isTablet ? 10.sp : 14.sp;
              final double dateFont = isTablet ? 8.sp : 12.sp;
              final double currencyFont = isTablet ? 8.sp : 12.sp;
              final double percentBadgeFont = isTablet ? 8.sp : 10.sp;
              final currencyFormatter =
                  NumberFormat.currency(locale: 'pt_BR', symbol: '');
              final currentValueStr =
                  currencyFormatter.format(goal.currentValue).trim();
              final targetValueStr = currencyFormatter.format(target).trim();
              final double prefixFont =
                  (currencyFont * (isTablet ? 0.75 : 0.85));

              return InkWell(
                onTap: () => Get.to(() => GoalDetailsPage(initialGoal: goal)),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.06),
                    ),
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
                                    fontSize: nameFont,
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
                                    fontSize: dateFont,
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
                          final double markerLeft =
                              (barWidth * clamped - 20).clamp(0, barWidth - 40);
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
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                  child: Text(
                                    '$percent%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: percentBadgeFont,
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
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'R\$ ',
                                  style: TextStyle(
                                    fontSize: prefixFont,
                                    color: DefaultColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: currentValueStr,
                                  style: TextStyle(
                                    fontSize: currencyFont,
                                    color: DefaultColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.end,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'R\$ ',
                                  style: TextStyle(
                                    fontSize: prefixFont,
                                    color: DefaultColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: targetValueStr,
                                  style: TextStyle(
                                    fontSize: currencyFont,
                                    color: DefaultColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
      );
    });
  }
}
