// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:organizamais/page/transaction/widget/title_transaction.dart';

import 'package:organizamais/utils/color.dart';

import '../../../controller/card_controller.dart';
import '../../../model/cards_model.dart';
import 'select_icon_page.dart';

class AddCardPage extends StatefulWidget {
  final bool isEditing;
  final CardsModel? card;

  const AddCardPage({
    super.key,
    required this.isEditing,
    this.card,
  });

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final nameController = TextEditingController();
  final limitController = TextEditingController();
  String? selectedIconPath;
  String? selectedBankName;
  final CardController cardController = Get.find();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.card != null) {
      nameController.text = widget.card!.name;
      limitController.text = widget.card!.limit.toString();
      selectedIconPath = widget.card!.iconPath;
      selectedBankName = widget.card!.bankName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.green,
        iconTheme: IconThemeData(
          color: DefaultColors.white,
        ),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          widget.isEditing ? 'Editar Cartão' : 'Criar Cartão',
          style: TextStyle(
            color: DefaultColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 20.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTitleTransaction(title: "Nome do cartão"),
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: 14.sp,
                color: DefaultColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Digite o nome do Cartão',
                hintStyle: TextStyle(
                  color: DefaultColors.grey,
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: DefaultColors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: DefaultColors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
            DefaultTitleTransaction(title: "Limite do cartão"),
            TextField(
              controller: limitController,
              style: TextStyle(
                fontSize: 14.sp,
                color: DefaultColors.black,
              ),
              decoration: InputDecoration(
                prefix: Text('R\$ '),
                hintText: 'Limtie do cartão',
                hintStyle: TextStyle(
                  color: DefaultColors.grey,
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: DefaultColors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: DefaultColors.grey,
                  ),
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () {
                Get.to(() => SelectIconPage(
                      onIconSelected: (path, name) {
                        setState(() {
                          selectedIconPath = path;
                          selectedBankName = name;
                        });
                      },
                    ));
              },
              child: Row(
                children: [
                  selectedIconPath != null
                      ? Row(
                          children: [
                            Image.asset(
                              selectedIconPath!,
                              width: 24.w,
                              height: 24.h,
                            ),
                            SizedBox(width: 8.w),
                            Text(selectedBankName ?? ''),
                          ],
                        )
                      : Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              8.r,
                            ),
                            child: Icon(
                              Iconsax.add,
                              size: 24.sp,
                              color: DefaultColors.black,
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Text(
                            'Selecione um ícone',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: DefaultColors.grey,
                            ),
                          ),
                        ]),
                ],
              ),
            ),
            Spacer(),
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                decoration: BoxDecoration(
                  color: DefaultColors.background,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: DefaultColors.green,
                  ),
                ),
                child: Text(
                  widget.isEditing ? 'Atualizar Cartão' : 'Adicionar Cartão',
                  style: TextStyle(
                    color: DefaultColors.green,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              onTap: () {
                if (nameController.text.isEmpty || limitController.text.isEmpty || selectedIconPath == null) {
                  Get.snackbar('Erro', 'Preencha todos os campos', snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                final cardData = CardsModel(
                  id: widget.isEditing ? widget.card!.id : null,
                  name: nameController.text,
                  limit: double.tryParse(limitController.text) ?? 0.0,
                  iconPath: selectedIconPath,
                  bankName: selectedBankName,
                  userId: widget.isEditing ? widget.card!.userId : null,
                );

                if (widget.isEditing) {
                  cardController.updateCard(cardData);
                } else {
                  cardController.addCard(cardData);
                }

                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
