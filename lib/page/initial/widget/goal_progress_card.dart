import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

class GoalProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String startDate;
  final String endDate;

  const GoalProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              CircleAvatar(
                child: const Icon(
                  Icons.savings,
                ),
              ),
              SizedBox(width: 10.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(startDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                  )),
              Text(endDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
