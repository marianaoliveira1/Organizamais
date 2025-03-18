import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../transaction/pages/category_page.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Definir Orçamento por Categoria'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        child: ListView.builder(
          itemCount: categories_expenses.length,
          itemBuilder: (context, index) {
            final category = categories_expenses[index];
            final controller = _controllers.putIfAbsent(
              category['id'],
              () => TextEditingController(),
            );

            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: category['color'].withOpacity(.1),
                    child: Padding(
                      padding: EdgeInsets.all(8.h),
                      child: Image.asset(category['icon'], height: 26.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 80.w,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'R\$ 0,00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 12.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Map<int, double> budgets = {};
          _controllers.forEach((id, controller) {
            final value = double.tryParse(controller.text) ?? 0.0;
            budgets[id] = value;
          });

          Get.snackbar('Sucesso', 'Orçamentos salvos!', snackPosition: SnackPosition.BOTTOM);
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
