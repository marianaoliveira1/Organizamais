import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  Widget _buildPieChart() {
    return SizedBox(
      height: 200.h,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: 35,
              color: Colors.blue,
              title: '35%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: DefaultColors.white,
              ),
            ),
            PieChartSectionData(
              value: 40,
              color: Colors.green,
              title: '40%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: DefaultColors.white,
              ),
            ),
            PieChartSectionData(
              value: 25,
              color: Colors.orange,
              title: '25%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: DefaultColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          children: [
            _buildPieChart(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: DefaultColors.background,
                            child: Icon(
                              Icons.home,
                              color: DefaultColors.black,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Casa",
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
                            "R\$ 4000,00",
                            style: TextStyle(
                              color: DefaultColors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            "5%",
                            style: TextStyle(
                              color: DefaultColors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
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
