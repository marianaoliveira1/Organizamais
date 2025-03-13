import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final ThemeData theme;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    var chartData = data
        .map(
          (e) => PieChartSectionData(
            value: e['value'] as double,
            color: e['color'] as Color,
            title: '${e['name']}',
            radius: 50,
            showTitle: false,
          ),
        )
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 180.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 26,
                centerSpaceColor: theme.scaffoldBackgroundColor,
                sections: chartData,
              ),
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
                          color: item['color'] as Color,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          item['name'] as String,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.primaryColor,
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
    );
  }
}
