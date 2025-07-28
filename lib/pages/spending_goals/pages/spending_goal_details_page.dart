import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../controller/spending_goal_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/spending_goal_model.dart';
import '../../../model/transaction_model.dart';
import '../../transaction/pages/category_page.dart';

class SpendingGoalDetailsPage extends StatelessWidget {
  final SpendingGoalModel spendingGoal;
  final SpendingGoalController spendingGoalController = Get.find();
  final TransactionController transactionController = Get.find();

  SpendingGoalDetailsPage({
    super.key,
    required this.spendingGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = findCategoryById(spendingGoal.categoryId);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          spendingGoal.name,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.trash,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, theme, category),
            SizedBox(height: 20.h),
            _buildProgressCard(context, theme),
            SizedBox(height: 20.h),
            _buildTransactionsSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ThemeData theme, Map<String, dynamic>? category) {
    final monthName = DateFormat.MMMM('pt_BR').format(
      DateTime(spendingGoal.year, spendingGoal.month),
    );

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (category != null)
                Image.asset(
                  category['icon'],
                  height: 48.h,
                  width: 48.w,
                )
              else
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.category,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?['name'] ?? 'Categoria não encontrada',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${monthName[0].toUpperCase()}${monthName.substring(1)} ${spendingGoal.year}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Limite definido',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
          Text(
            spendingGoalController.formatCurrency(spendingGoal.limitValue),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ThemeData theme) {
    final spentAmount = spendingGoalController.calculateSpentAmount(
      spendingGoal.categoryId,
      spendingGoal.month,
      spendingGoal.year,
    );
    final progress = spendingGoalController.calculateProgress(spendingGoal);
    final isExceeded = spendingGoalController.isGoalExceeded(spendingGoal);
    final remainingAmount = spendingGoalController.getRemainingAmount(spendingGoal);

    Color progressColor = isExceeded 
        ? Colors.red 
        : progress > 0.8 
            ? Colors.orange 
            : Colors.green;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: isExceeded 
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              if (isExceeded)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'LIMITE ULTRAPASSADO',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gasto atual',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    spendingGoalController.formatCurrency(spentAmount),
                    style: TextStyle(
                      fontSize: 18.sp,
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
                    isExceeded ? 'Excesso' : 'Restante',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    spendingGoalController.formatCurrency(remainingAmount.abs()),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isExceeded ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
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
          Center(
            child: Text(
              '${(progress * 100).toStringAsFixed(1)}% do limite',
              style: TextStyle(
                fontSize: 12.sp,
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, ThemeData theme) {
    final transactions = _getTransactionsForGoal();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transações da categoria (${transactions.length})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.receipt_minus,
                          size: 48.sp,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Nenhuma transação nesta categoria',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(transaction, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction, ThemeData theme) {
    final value = double.tryParse(
      transaction.value.replaceAll('.', '').replaceAll(',', '.'),
    ) ?? 0.0;
    
    final date = transaction.paymentDay != null 
        ? DateTime.parse(transaction.paymentDay!)
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                if (date != null)
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            spendingGoalController.formatCurrency(value),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getTransactionsForGoal() {
    return transactionController.transaction
        .where((transaction) {
          if (transaction.paymentDay == null) return false;
          if (transaction.type != TransactionType.despesa) return false;
          if (transaction.category != spendingGoal.categoryId) return false;
          
          final paymentDate = DateTime.parse(transaction.paymentDay!);
          return paymentDate.month == spendingGoal.month && 
                 paymentDate.year == spendingGoal.year;
        })
        .toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.paymentDay!);
        final dateB = DateTime.parse(b.paymentDay!);
        return dateB.compareTo(dateA); // Mais recente primeiro
      });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Excluir Meta',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta meta de gasto?',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              spendingGoalController.deleteSpendingGoal(spendingGoal.id!);
              Get.back(); // Fecha o dialog
              Get.back(); // Volta para a lista
            },
            child: Text(
              'Excluir',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 