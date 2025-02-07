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
    Key? key,
    this.type,
  }) : super(key: key);

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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: DefaultColors.greyLight,
                  borderRadius: BorderRadius.circular(8),
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
                    IconButton(
                      icon: Icon(
                        Iconsax.arrow_down_2,
                      ),
                      onPressed: () {
                        Get.to(() => Category());
                      },
                    ),
                  ],
                ),
              ),
              DefaultTitleTransaction(
                title: "Data",
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "dd/mm/aaaa",
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Iconsax.calendar_1,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate)
                          setState(() {
                            selectedDate = picked;
                          });
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
