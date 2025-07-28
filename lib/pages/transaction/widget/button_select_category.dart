import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../model/transaction_model.dart';
import '../../../utils/color.dart';
import '../pages/category_page.dart';

class DefaultButtonSelectCategory extends StatelessWidget {
  const DefaultButtonSelectCategory({
    super.key,
    required this.onTap,
    required this.selectedCategory,
    this.transactionType,
  });

  final Function(int?) onTap;
  final int? selectedCategory;
  final TransactionType? transactionType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategoryData = findCategoryById(selectedCategory);

    return InkWell(
      onTap: () async {
        var categoryId = await Get.to(() => CategoryPage(
              transactionType: transactionType,
            ));
        onTap(categoryId as int?);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
          horizontal: 5.w,
        ),
        child: Row(
          children: [
            if (selectedCategoryData != null)
              Image.asset(
                selectedCategoryData['icon'],
                height: 30.h,
                width: 30.w,
              )
            else
              Icon(
                Iconsax.textalign_justifycenter,
                color: DefaultColors.grey20,
              ),
            SizedBox(width: 10.w),
            Text(
              selectedCategoryData != null
                  ? selectedCategoryData['name']
                  : 'Selecione uma categoria',
              style: TextStyle(
                color: selectedCategoryData != null
                    ? theme.primaryColor
                    : DefaultColors.grey20,
                fontSize: 17.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
