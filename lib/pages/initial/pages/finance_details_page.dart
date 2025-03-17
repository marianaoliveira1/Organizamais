// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class FinanceDetailsPage extends StatelessWidget {
  const FinanceDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.find<TransactionController>();
    final theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.currency(
      locale: "pt_BR",
      symbol: "R\$",
    );

    // Pega o mês e o ano atuais
    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    // Nome do mês atual
    final String currentMonthName = DateFormat('MMMM', 'pt_BR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalhes Financeiros - $currentMonthName",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        // Filtra transações de receita para o mês atual
        final receivedTransactions = transactionController.transaction.where((t) {
          if (t.paymentDay != null) {
            DateTime paymentDate = DateTime.parse(t.paymentDay!);
            return t.type == TransactionType.receita && paymentDate.month == currentMonth && paymentDate.year == currentYear;
          }
          return false;
        }).toList();

        // Filtra transações de despesa para o mês atual
        final expenseTransactions = transactionController.transaction.where((t) {
          if (t.paymentDay != null) {
            DateTime paymentDate = DateTime.parse(t.paymentDay!);
            return t.type == TransactionType.despesa && paymentDate.month == currentMonth && paymentDate.year == currentYear;
          }
          return false;
        }).toList();

        // Calcula totais
        num totalReceitas = receivedTransactions.fold(
          0,
          (sum, t) => sum + double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')),
        );

        num totalDespesas = expenseTransactions.fold(
          0,
          (sum, t) => sum + double.parse(t.value.replaceAll('.', '').replaceAll(',', '.')),
        );

        num saldoTotal = totalReceitas - totalDespesas;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de resumo
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Resumo do Mês",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          "Total Receitas",
                          formatter.format(totalReceitas),
                          DefaultColors.green,
                        ),
                        _buildSummaryItem(
                          "Total Despesas",
                          formatter.format(totalDespesas),
                          DefaultColors.red,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Divider(),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Saldo",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatter.format(saldoTotal),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: saldoTotal >= 0 ? DefaultColors.green : DefaultColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Seção de receitas
              Text(
                "Receitas",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.green,
                ),
              ),
              SizedBox(height: 8.h),
              receivedTransactions.isEmpty
                  ? _buildEmptyState("Nenhuma receita registrada neste mês")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: receivedTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = receivedTransactions[index];
                        final paymentDate = DateTime.parse(transaction.paymentDay!);
                        final formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);

                        return _buildTransactionCard(
                          transaction.title,
                          formatter.format(double.parse(transaction.value.replaceAll('.', '').replaceAll(',', '.'))),
                          formattedDate,
                          DefaultColors.green,
                          transaction.paymentType ?? "Não especificado",
                          transaction.category ?? 0,
                        );
                      },
                    ),

              SizedBox(height: 24.h),

              // Seção de despesas
              Text(
                "Despesas",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.red,
                ),
              ),
              SizedBox(height: 8.h),
              expenseTransactions.isEmpty
                  ? _buildEmptyState("Nenhuma despesa registrada neste mês")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: expenseTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = expenseTransactions[index];
                        final paymentDate = DateTime.parse(transaction.paymentDay!);
                        final formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);

                        return _buildTransactionCard(
                          transaction.title,
                          formatter.format(double.parse(transaction.value.replaceAll('.', '').replaceAll(',', '.'))),
                          formattedDate,
                          DefaultColors.red,
                          transaction.paymentType ?? "Não especificado",
                          transaction.category ?? 0,
                        );
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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

  Widget _buildTransactionCard(
    String title,
    String value,
    String date,
    Color color,
    String paymentType,
    int categoryId,
  ) {
    // Lista de possíveis ícones baseados na categoria
    // Você pode expandir isso ou relacionar com suas categorias existentes
    final List<IconData> categoryIcons = [
      Icons.home,
      Icons.fastfood,
      Icons.shopping_cart,
      Icons.directions_car,
      Icons.medical_services,
      Icons.school,
      Icons.celebration,
      Icons.sports,
      Icons.work,
      Icons.attach_money,
    ];

    final IconData icon = categoryId < categoryIcons.length ? categoryIcons[categoryId] : Icons.receipt_long;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.payment,
                  size: 12.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Text(
                  paymentType,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: color,
          ),
        ),
      ),
    );
  }
}
