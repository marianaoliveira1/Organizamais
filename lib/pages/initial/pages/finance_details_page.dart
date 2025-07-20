import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../transaction/transaction_page.dart';

class FinanceDetailsPage extends StatelessWidget {
  const FinanceDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    final theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    // Pega o mês e o ano atuais
    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Obx(() {
        // Filtra transações de receita para o mês atual
        final receivedTransactions =
            transactionController.transaction.where((t) {
          if (t.paymentDay != null) {
            DateTime paymentDate = DateTime.parse(t.paymentDay!);
            return t.type == TransactionType.receita &&
                paymentDate.month == currentMonth &&
                paymentDate.year == currentYear;
          }
          return false;
        }).toList();

        // Ordena por data mais recente primeiro
        receivedTransactions.sort((a, b) {
          DateTime dateA = DateTime.parse(a.paymentDay!);
          DateTime dateB = DateTime.parse(b.paymentDay!);
          return dateB.compareTo(
              dateA); // Ordenação decrescente (mais recente primeiro)
        });

        // Filtra transações de despesa para o mês atual
        final expenseTransactions =
            transactionController.transaction.where((t) {
          if (t.paymentDay != null) {
            DateTime paymentDate = DateTime.parse(t.paymentDay!);
            return t.type == TransactionType.despesa &&
                paymentDate.month == currentMonth &&
                paymentDate.year == currentYear;
          }
          return false;
        }).toList();

        // Ordena por data mais recente primeiro
        expenseTransactions.sort((a, b) {
          DateTime dateA = DateTime.parse(a.paymentDay!);
          DateTime dateB = DateTime.parse(b.paymentDay!);
          return dateB.compareTo(
              dateA); // Ordenação decrescente (mais recente primeiro)
        });

        return Column(
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Receitas",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    receivedTransactions.isEmpty
                        ? _buildEmptyState(
                            "Nenhuma receita registrada neste mês")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: receivedTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = receivedTransactions[index];
                              return TransactionCard(
                                transaction: transaction,
                              );
                            },
                          ),

                    // Seção de despesas
                    Text(
                      "Despesas",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    expenseTransactions.isEmpty
                        ? _buildEmptyState(
                            "Nenhuma despesa registrada neste mês")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: expenseTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = expenseTransactions[index];
                              return TransactionCard(
                                transaction: transaction,
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      width: double.infinity,
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 40.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final paymentDate = DateTime.parse(transaction.paymentDay!);
    final formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);
    final double value = double.parse(transaction.value.replaceAll('.', '').replaceAll(',', '.'));
    final NumberFormat formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return InkWell(
      onTap: () => Get.to(
        () => TransactionPage(
          transaction: transaction,
          overrideTransactionSalvar: (updatedTransaction) {
            final controller = Get.find<TransactionController>();
            controller.updateTransaction(updatedTransaction);
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Text(
                    transaction.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: theme.primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatter.format(value),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  width: 150.w,
                  child: Text(
                    transaction.paymentType ?? "Não especificado",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
