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
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: data.map((e) => e['chart']).toList().cast<PieChartSectionData>(),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.h,
                horizontal: 16.w,
              ),
              decoration: BoxDecoration(
                color: DefaultColors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gastos por categoria",
                    style: TextStyle(
                      color: DefaultColors.grey,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  for (var item in data)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: DefaultColors.background,
                                  child: Image.asset(
                                    item['icon'] ?? '',
                                    width: 24.w,
                                    height: 24.h,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  item['chart']?.title ?? '',
                                  style: TextStyle(
                                    color: DefaultColors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "R\$ ${item['chart']?.value}",
                                  style: TextStyle(
                                    color: DefaultColors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  "${((item['chart']?.value ?? 0) / totalValue * 100).toStringAsFixed(2)}%",
                                  style: TextStyle(
                                    color: DefaultColors.grey,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Divider(
                          color: DefaultColors.grey,
                          height: 10.h,
                        ),
                      ],
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
