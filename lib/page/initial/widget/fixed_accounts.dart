import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:organizamais/utils/color.dart';

class FixedAccounts extends StatelessWidget {
  const FixedAccounts({
    super.key,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contas fixas",
                style: TextStyle(
                  color: DefaultColors.grey,
                  fontSize: 12.sp,
                ),
              ),
              Icon(Icons.add),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.home,
                    size: 30.h,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Aluguel",
                        style: TextStyle(
                          color: DefaultColors.black,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "Pix",
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "R\$ 1.200,00",
                    style: TextStyle(
                      color: DefaultColors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    "15 jan 2025",
                    style: TextStyle(
                      color: DefaultColors.grey,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
