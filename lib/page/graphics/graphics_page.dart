import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

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
            SizedBox(
              height: 200.h,
              child: CustomBarChart(),
            ),
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
                          Text("Casa"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("R\$ 4000,00"),
                          Text("5%",
                              style: TextStyle(
                                color: DefaultColors.grey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              )),
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

class CustomBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 300,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: EdgeInsets.all(8),
                tooltipMargin: 8,
                tooltipRoundedRadius: 8,
                tooltipBorder: BorderSide(color: Colors.black),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '-\$${rod.toY.toStringAsFixed(2)}',
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    List<String> months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug'
                    ];
                    return Text(months[value.toInt()], style: TextStyle(fontWeight: FontWeight.bold));
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              _buildBar(0, 100, Colors.pinkAccent),
              _buildBar(1, 284, Colors.pink),
              _buildBar(2, 150, Colors.pinkAccent),
              _buildBar(3, 170, Colors.pink),
              _buildBar(4, 200, Colors.pinkAccent),
              _buildBar(5, 80, Colors.pink),
              _buildBar(6, 90, Colors.pinkAccent),
              _buildBar(7, 120, Colors.pink),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,
          borderRadius: BorderRadius.circular(6), // Deixa as bordas arredondadas
          color: color,
        ),
      ],
    );
  }
}
