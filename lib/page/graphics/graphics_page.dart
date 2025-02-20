import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/page/transaction/pages/%20category.dart';
import 'package:organizamais/utils/color.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());
    var categories = transactionController.transaction.map((e) => e.category).toSet().toList();
    var data = categories
        .map(
          (e) => {
            "chart": PieChartSectionData(
              value: transactionController.transaction.where((element) => element.category == e).fold(0, (previousValue, element) {
                return (previousValue ?? 0) + double.parse(element.value);
              }),
              color: findCategoryById(e)?['color'],
              title: '${findCategoryById(e)?['name']}',
              radius: 50,
              showTitle: false, // Remove os títulos do gráfico
            ),
            "icon": findCategoryById(e)?['icon'],
          },
        )
        .toList();

    double totalValue = data.fold(
      0,
      (previousValue, element) => previousValue + (element['chart']?.value ?? 0),
    );

    return Scaffold(
      backgroundColor: DefaultColors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Pie Chart
            SizedBox(
              height: 200.h,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: data.map((e) => e['chart']).toList().cast<PieChartSectionData>(),
                      ),
                    ),
                  ),
                  // Legend
                  SizedBox(
                    width: 120.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var item in data)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 12.w,
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                    color: item['chart']?.color,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  item['chart']?.title ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: DefaultColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Categories List with Mini Charts
            for (var item in data)
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  children: [
                    // Mini Pie Chart
                    SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 20,
                          sections: [
                            PieChartSectionData(
                              value: item['chart']?.value ?? 0,
                              color: item['chart']?.color ?? DefaultColors.grey,
                              radius: 25,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: totalValue - (item['chart']?.value ?? 0),
                              color: DefaultColors.background,
                              radius: 25,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Category Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['chart']?.title ?? '',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: DefaultColors.black,
                            ),
                          ),
                          Text(
                            "${((item['chart']?.value ?? 0) / totalValue * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: DefaultColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Text(
                      "R\$ ${item['chart']?.value?.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.black,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
