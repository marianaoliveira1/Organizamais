import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';
import '../../../ads_banner/ads_banner.dart';

class FinancialAnalysisDetailPage extends StatelessWidget {
  const FinancialAnalysisDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Análise Financeira Detalhada",
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          AdsBanner(),
          SizedBox(height: 5.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Obx(() {
                final monthlyAnalysis =
                    _generateMonthlyAnalysis(controller.transaction);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Análise Mensal Comparativa
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Evolução Mensal",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ...monthlyAnalysis
                              .map((item) => _buildAnalysisItem(item, theme)),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: item['cardColor'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: item['cardColor'].withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                item['icon'],
                color: item['cardColor'],
                size: 20.sp,
              ),
              SizedBox(
                width: 6.w,
              ),
              Text(
                item['month'],
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                item['analysis'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item['message'],
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: item['cardColor'],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receitas',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DefaultColors.grey,
                    ),
                  ),
                  Text(
                    _formatCurrency(item['receitas']),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Despesas',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: DefaultColors.grey,
                    ),
                  ),
                  Text(
                    _formatCurrency(item['despesas']),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Saldo',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: DefaultColors.grey,
                ),
              ),
              SizedBox(
                width: 6.w,
              ),
              Text(
                _formatCurrency(item['saldo']),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: item['saldo'] >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          )
        ],
      ),
      // child: Row(
      //   children: [
      //     Column(
      //       children: [
      //
      //       ],
      //     ),
      //     SizedBox(width: 12.w),
      //     Expanded(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           SizedBox(height: 4.h),
      //           Text(
      //             item['analysis'],
      //             style: TextStyle(
      //               fontSize: 13.sp,
      //               fontWeight: FontWeight.bold,
      //               color: DefaultColors.grey,
      //             ),
      //           ),
      //           SizedBox(height: 4.h),
      //           Text(
      //             item['message'],
      //             style: TextStyle(
      //               fontSize: 11.sp,
      //               fontWeight: FontWeight.w500,
      //               color: item['cardColor'],
      //             ),
      //           ),
      //           SizedBox(height: 8.h),
      //           Row(
      //             children: [
      //               Expanded(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       'Receitas',
      //                       style: TextStyle(
      //                         fontSize: 10.sp,
      //                         color: DefaultColors.grey,
      //                       ),
      //                     ),
      //                     Text(
      //                       _formatCurrency(item['receitas']),
      //                       style: TextStyle(
      //                         fontSize: 12.sp,
      //                         fontWeight: FontWeight.bold,
      //                         color: Colors.green,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               Expanded(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       'Despesas',
      //                       style: TextStyle(
      //                         fontSize: 10.sp,
      //                         color: DefaultColors.grey,
      //                       ),
      //                     ),
      //                     Text(
      //                       _formatCurrency(item['despesas']),
      //                       style: TextStyle(
      //                         fontSize: 12.sp,
      //                         fontWeight: FontWeight.bold,
      //                         color: Colors.red,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               Expanded(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       'Saldo',
      //                       style: TextStyle(
      //                         fontSize: 10.sp,
      //                         color: DefaultColors.grey,
      //                       ),
      //                     ),
      //                     Text(
      //                       _formatCurrency(item['saldo']),
      //                       style: TextStyle(
      //                         fontSize: 12.sp,
      //                         fontWeight: FontWeight.bold,
      //                         color: item['saldo'] >= 0
      //                             ? Colors.green
      //                             : Colors.red,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  List<Map<String, dynamic>> _generateMonthlyAnalysis(
      List<TransactionModel> transactions) {
    List<Map<String, dynamic>> analysis = [];
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    for (int month = 2; month <= currentMonth; month++) {
      final currentMonthData = _getMonthData(transactions, month, currentYear);
      final previousMonthData =
          _getMonthData(transactions, month - 1, currentYear);

      if ((currentMonthData['receitas'] ?? 0.0) > 0 ||
          (currentMonthData['despesas'] ?? 0.0) > 0 ||
          (previousMonthData['receitas'] ?? 0.0) > 0 ||
          (previousMonthData['despesas'] ?? 0.0) > 0) {
        double receitasDiff = (currentMonthData['receitas'] ?? 0.0) -
            (previousMonthData['receitas'] ?? 0.0);
        double despesasDiff = (currentMonthData['despesas'] ?? 0.0) -
            (previousMonthData['despesas'] ?? 0.0);
        double saldoDiff = (currentMonthData['saldo'] ?? 0.0) -
            (previousMonthData['saldo'] ?? 0.0);

        double receitasPercentChange = 0;
        double despesasPercentChange = 0;

        if ((previousMonthData['receitas'] ?? 0.0) > 0) {
          receitasPercentChange =
              (receitasDiff / (previousMonthData['receitas'] ?? 1.0)) * 100;
        } else if ((currentMonthData['receitas'] ?? 0.0) > 0) {
          receitasPercentChange = 100;
        }

        if ((previousMonthData['despesas'] ?? 0.0) > 0) {
          despesasPercentChange =
              (despesasDiff / (previousMonthData['despesas'] ?? 1.0)) * 100;
        } else if ((currentMonthData['despesas'] ?? 0.0) > 0) {
          despesasPercentChange = 100;
        }

        Color cardColor;
        IconData icon;
        String message;

        if (saldoDiff > 0) {
          cardColor = Colors.green;
          icon = Icons.arrow_upward;
          message = "Melhoria no saldo!";
        } else if (saldoDiff >= -100) {
          cardColor = Colors.orange;
          icon = Icons.circle;
          message = "Saldo estável";
        } else {
          cardColor = Colors.red;
          icon = Icons.arrow_downward;
          message = "Atenção ao saldo!";
        }

        String analysisText = '';
        if (receitasDiff != 0) {
          analysisText +=
              'Receitas: ${receitasDiff >= 0 ? '+' : ''}${_formatCurrency(receitasDiff)} (${receitasPercentChange.toStringAsFixed(1)}%) ';
        }
        if (despesasDiff != 0) {
          analysisText +=
              'Despesas: ${despesasDiff >= 0 ? '+' : ''}${_formatCurrency(despesasDiff)} (${despesasPercentChange.toStringAsFixed(1)}%)';
        }

        analysis.add({
          'month': _getMonthName(month),
          'analysis': analysisText,
          'message': message,
          'cardColor': cardColor,
          'icon': icon,
          'receitas': currentMonthData['receitas'],
          'despesas': currentMonthData['despesas'],
          'saldo': currentMonthData['saldo'],
        });
      }
    }

    return analysis;
  }

  Map<String, double> _getMonthData(
      List<TransactionModel> transactions, int month, int year) {
    double receitas = 0.0;
    double despesas = 0.0;

    for (final transaction in transactions) {
      if (transaction.paymentDay != null) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        if (paymentDate.month == month && paymentDate.year == year) {
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );

          if (transaction.type == TransactionType.receita) {
            receitas += value;
          } else {
            despesas += value;
          }
        }
      }
    }

    return {
      'receitas': receitas,
      'despesas': despesas,
      'saldo': receitas - despesas,
    };
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }

  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final formatted =
        absValue.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );

    return '${isNegative ? '-' : ''}R\$ $formatted';
  }
}
