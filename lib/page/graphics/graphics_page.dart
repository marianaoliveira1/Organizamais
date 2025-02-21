import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/page/transaction/pages/category_page.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/model/transaction_model.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.put(TransactionController());

    // Filtrar apenas despesas
    var despesas = transactionController.transaction.where((e) => e.type == TransactionType.despesa).toList();
    var categories = despesas.map((e) => e.category).toSet().toList();

    var data = categories
        .map(
          (e) => {
            "chart": PieChartSectionData(
              value: despesas.where((element) => element.category == e).fold(0, (previousValue, element) {
                return (previousValue ?? 0) + double.parse(element.value);
              }),
              color: findCategoryById(e)?['color'],
              title: '${findCategoryById(e)?['name']}',
              radius: 50,
              showTitle: false,
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
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(
              height: 180.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 26,
                        centerSpaceColor: DefaultColors.background,
                        sections: data.map((e) => e['chart']).toList().cast<PieChartSectionData>(),
                      ),
                    ),
                  ),
                  SizedBox(width: 26.w),
                  Expanded(
                    flex: 1,
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
                                  width: 10.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: item['chart']?.color,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    item['chart']?.title ?? '',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: DefaultColors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
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
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                var item = data[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Row(
                    children: [
                      Container(
                        width: 45.w,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: DefaultColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 15,
                            centerSpaceColor: DefaultColors.background,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                value: item['chart']?.value ?? 0,
                                color: item['chart']?.color ?? Colors.grey,
                                radius: 15,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: totalValue - (item['chart']?.value ?? 0),
                                color: DefaultColors.background,
                                radius: 15,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['chart']?.title ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "${((item['chart']?.value ?? 0) / totalValue * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "R\$${item['chart']?.value?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
