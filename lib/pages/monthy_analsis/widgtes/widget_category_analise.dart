import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/pages/monthy_analsis/widgtes/category_analise_page.dart'
    show CategoryAnalysisPage;

import 'package:organizamais/utils/color.dart';

class WidgetCategoryAnalise extends StatelessWidget {
  const WidgetCategoryAnalise({
    super.key,
    required this.data,
    required this.monthName,
    required this.totalValue,
    required this.theme,
    required this.currencyFormatter,
  });

  final List<Map<String, dynamic>> data;
  final double totalValue;
  final String monthName;
  final ThemeData theme;
  final NumberFormat currencyFormatter;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        var categoryId = item['category'] as int;
        var valor = item['value'] as double;
        var percentual = (valor / totalValue * 100);
        var categoryColor = item['color'] == null
            ? Colors.grey.withOpacity(0.5)
            : item['color'] as Color;
        var categoryIcon = item['icon'] as String?;

        return Column(
          children: [
            // Item da categoria
            GestureDetector(
              onTap: () {
                // Navega para a página de análise da categoria
                Get.to(() => CategoryAnalysisPage(
                      categoryId: categoryId,
                      categoryName: item['name'] as String,
                      categoryColor: categoryColor,
                      monthName: monthName,
                      totalValue: valor,
                      percentual: percentual,
                    ));
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 10.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      // Ícone da categoria
                      Container(
                        width: 30.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Image.asset(
                            categoryIcon ?? 'assets/icons/category.png',
                            width: 20.w,
                            height: 20.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110.w,
                              child: Text(
                                item['name'] == null
                                    ? 'Categoria não encontrada'
                                    : item['name'] as String,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.start,
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Text(
                              "${percentual.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: DefaultColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(valor),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: DefaultColors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
