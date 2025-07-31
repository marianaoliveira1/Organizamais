import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../ads_banner/ads_banner.dart';
import '../../controller/spending_goal_controller.dart';
import '../../model/spending_goal_model.dart';
import '../transaction/pages/category_page.dart';
import 'pages/add_spending_goal_page.dart';
import 'pages/spending_goal_details_page.dart';

class SpendingGoalsPage extends StatelessWidget {
  final SpendingGoalController spendingGoalController =
      Get.put(SpendingGoalController());

  SpendingGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    spendingGoalController.startSpendingGoalStream();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Metas de Gasto',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suas Metas',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                InkWell(
                  onTap: () => Get.to(() => AddSpendingGoalPage()),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(60.r),
                    ),
                    padding: EdgeInsets.all(8.h),
                    child: Icon(
                      Iconsax.add,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Controle seus gastos por categoria',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.h),
            _buildMonthSelector(theme),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() {
                final currentGoals =
                    spendingGoalController.getCurrentMonthGoals();

                if (currentGoals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.chart_2,
                          size: 64.sp,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Nenhuma meta de gasto encontrada',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Adicione uma meta para começar a controlar seus gastos',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: currentGoals.length,
                  itemBuilder: (context, index) {
                    final SpendingGoalModel goal = currentGoals[index];
                    return _buildGoalCard(context, goal, theme);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme) {
    final now = DateTime.now();
    final monthName = DateFormat.MMMM('pt_BR').format(now);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.calendar_1,
            size: 18.sp,
            color: theme.primaryColor,
          ),
          SizedBox(width: 8.w),
          Text(
            '${monthName[0].toUpperCase()}${monthName.substring(1)} ${now.year}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, SpendingGoalModel goal, ThemeData theme) {
    final category = findCategoryById(goal.categoryId);
    final spentAmount = spendingGoalController.calculateSpentAmount(
      goal.categoryId,
      goal.month,
      goal.year,
    );
    final progress = spendingGoalController.calculateProgress(goal);
    final isExceeded = spendingGoalController.isGoalExceeded(goal);
    final remainingAmount = spendingGoalController.getRemainingAmount(goal);

    Color progressColor = isExceeded
        ? Colors.red
        : progress > 0.8
            ? Colors.orange
            : Colors.green;

    return InkWell(
      onTap: () => Get.to(() => SpendingGoalDetailsPage(spendingGoal: goal)),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: isExceeded
              ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone da categoria
                  if (category != null)
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Image.asset(
                        category['icon'],
                        height: 24.h,
                        width: 24.w,
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.category,
                        color: Colors.grey.shade600,
                        size: 20.sp,
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          category?['name'] ?? 'Categoria não encontrada',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Data da meta
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      DateFormat('MMM/yy', 'pt_BR')
                          .format(DateTime(goal.year, goal.month)),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Valores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gasto',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        spendingGoalController.formatCurrency(spentAmount),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isExceeded ? Colors.red : theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Limite',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        spendingGoalController.formatCurrency(goal.limitValue),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8.h,
                ),
              ),

              SizedBox(height: 8.h),

              // Status e porcentagem
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isExceeded
                        ? 'Limite ultrapassado!'
                        : 'Restante: ${spendingGoalController.formatCurrency(remainingAmount)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isExceeded ? Colors.red : Colors.grey,
                      fontWeight:
                          isExceeded ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
