// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/utils/color.dart';

import 'pages/  category.dart';
import 'widget/text_field_transaction.dart';
import 'widget/title_transaction.dart';

class TransactionPage extends StatefulWidget {
  final String? type;

  const TransactionPage({
    super.key,
    this.type,
  });

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTitleTransaction(
                title: 'Valor',
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  Expanded(
                    child: DefaultTextFieldTransaction(
                      hintText: '0,00',
                      controller: valueController,
                      icon: Icon(
                        Icons.attach_money,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              DefaultTitleTransaction(
                title: 'Título',
              ),
              SizedBox(
                height: 10.h,
              ),
              DefaultTextFieldTransaction(
                hintText: 'Ex: Compra de mercado',
                controller: titleController,
              ),
              SizedBox(height: 16),
              DefaultTitleTransaction(
                title: "Categoria",
              ),
              InkWell(
                onTap: () {
                  Get.to(
                    () => Category(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.h,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: DefaultColors.greyLight,
                    borderRadius: BorderRadius.circular(
                      14.r,
                    ),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Selecione",
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                      Icon(
                        Iconsax.arrow_down_2,
                      ),
                    ],
                  ),
                ),
              ),
              DefaultTitleTransaction(
                title: "Data",
              ),
              SizedBox(
                height: 10.h,
              ),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2015, 8),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.h,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      14.r,
                    ),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "dd/mm/aaaa",
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                      Icon(
                        Iconsax.calendar_1,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    //button save
                    child: Container(
                      margin: EdgeInsets.only(top: 20.h),
                      padding: EdgeInsets.all(16.h),
                      decoration: BoxDecoration(
                        color: DefaultColors.grey,
                        borderRadius: BorderRadius.circular(
                          32.r,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            color: DefaultColors.black,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    //button save
                    child: Container(
                      margin: EdgeInsets.only(top: 20.h),
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: DefaultColors.black,
                        borderRadius: BorderRadius.circular(
                          32.r,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Salvar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
