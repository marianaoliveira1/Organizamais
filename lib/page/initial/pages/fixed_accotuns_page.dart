import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import '../../transaction_page.dart/transaction_page.dart';
import '../../transaction_page.dart/widget/text_field_transaction.dart';
import '../../transaction_page.dart/widget/title_transaction.dart';

class FixedAccotunsPage extends StatelessWidget {
  const FixedAccotunsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController daytionController = TextEditingController();

    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
        title: const Text("Contas fixas"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.w,
          horizontal: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTitleTransaction(
              title: "Titulo",
            ),
            DefaultTextFieldTransaction(
              hintText: 'Titulo',
              controller: titleController,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Valor",
            ),
            DefaultTextFieldTransaction(
              hintText: 'Valor',
              controller: valueController,
              icon: Icon(
                Icons.attach_money,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Categoria",
            ),
            DefaultButtonCategory(),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(
              title: "Dia do pagamento",
            ),
            DefaultTextFieldTransaction(
              hintText: 'Dia do pagamento',
              controller: valueController,
              keyboardType: TextInputType.number,
            ),
            Spacer(),
            Container(
              width: 1.sw,
              height: 50.h,
              decoration: BoxDecoration(
                color: DefaultColors.black,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Salvar",
                  style: TextStyle(
                    color: DefaultColors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
