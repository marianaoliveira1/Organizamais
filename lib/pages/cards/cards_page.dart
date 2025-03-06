import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/card_controller.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CardController cardController = Get.put(CardController());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 20.h,
            horizontal: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cardController.card.length,
                  separatorBuilder: (context, index) => SizedBox(
                    height: 14.h,
                  ),
                  itemBuilder: (context, index) {
                    final card = cardController.card[index];
                    return GestureDetector(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (card.iconPath != null)
                                Image.asset(
                                  card.iconPath!,
                                  width: 30.w,
                                  height: 30.h,
                                ),
                              SizedBox(
                                width: 20.w,
                              ),
                              Expanded(
                                child: Text(
                                  card.name,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
