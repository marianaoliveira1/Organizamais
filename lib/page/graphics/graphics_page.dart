import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: Column(
        children: [
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
              children: [
                Text(
                  "Total",
                  style: TextStyle(
                    color: DefaultColors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
