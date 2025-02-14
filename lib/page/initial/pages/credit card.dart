import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';

import '../../transaction/widget/title_transaction.dart';

class CreditCardPage extends StatelessWidget {
  const CreditCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController limitController = TextEditingController();

    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.h,
          vertical: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTitleTransaction(
              title: 'Nome do Cartão',
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Digite o nome do cartão',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: DefaultColors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(
                    color: DefaultColors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            DefaultTitleTransaction(
              title: 'Escolha um ícone',
            ),
            InkWell(
              onTap: () {
                Get.toNamed("/bank");
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 15.h,
                ),
                decoration: BoxDecoration(
                  color: DefaultColors.greyLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: DefaultColors.grey),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: DefaultColors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      'Selecione um icone',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: DefaultColors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            DefaultTitleTransaction(
              title: 'Limite do cartão',
            ),
            TextField(
              controller: limitController,
              decoration: InputDecoration(
                hintText: 'Digite o limite do cartão',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: DefaultColors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: BorderSide(
                    color: DefaultColors.grey,
                  ),
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 15.h,
                ),
                decoration: BoxDecoration(
                  color: DefaultColors.green,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    'Adicionar Cartão',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DefaultColors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
