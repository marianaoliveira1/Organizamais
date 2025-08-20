// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:organizamais/pages/transaction/widget/title_transaction.dart';

import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/card_controller.dart';
import '../../../model/cards_model.dart';
import 'select_icon_page.dart';
import '../../../routes/route.dart';
import '../../../widgetes/currency_ipunt_formated.dart';

class AddCardPage extends StatefulWidget {
  final bool isEditing;
  final CardsModel? card;
  final bool fromOnboarding;

  const AddCardPage({
    super.key,
    required this.isEditing,
    this.card,
    this.fromOnboarding = false,
  });

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final nameController = TextEditingController();
  final limitController = TextEditingController();
  final closingDayController = TextEditingController();
  String? selectedIconPath;
  String? selectedBankName;
  final CardController cardController = Get.find();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.card != null) {
      nameController.text = widget.card!.name;
      limitController.text = widget.card!.limit?.toString() ?? '';
      selectedIconPath = widget.card!.iconPath;
      selectedBankName = widget.card!.bankName;
      closingDayController.text = widget.card!.closingDay?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            DefaultTitleTransaction(title: "Nome do cartão"),
            SizedBox(
              height: 10.h,
            ),
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.primaryColor,
              ),
              decoration: InputDecoration(
                hintText: 'Digite o nome do Cartão',
                hintStyle: TextStyle(
                  color: theme.primaryColor.withOpacity(0.5),
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(0.5),
                    // color: DefaultColors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            DefaultTitleTransaction(title: "Limite do cartão"),
            TextField(
              controller: limitController,
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.primaryColor,
              ),
              decoration: InputDecoration(
                hintText: 'Limite do cartão (R\$)',
                hintStyle: TextStyle(
                  color: theme.primaryColor.withOpacity(0.5),
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(0.5),
                  ),
                ),
              ),
              inputFormatters: [
                CurrencyInputFormatter(),
              ],
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.h),
            DefaultTitleTransaction(title: "Fecha no dia"),
            TextField(
              controller: closingDayController,
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.primaryColor,
              ),
              decoration: InputDecoration(
                hintText: 'Dia de fechamento (1 a 31)',
                hintStyle: TextStyle(
                  color: theme.primaryColor.withOpacity(0.5),
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withOpacity(0.5),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
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
                              width: 40.w,
                              height: 40.h,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              selectedBankName ?? '',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        )
                      : Row(children: [
                          Container(
                            padding: EdgeInsets.all(
                              8.h,
                            ),
                            decoration: BoxDecoration(
                              color: DefaultColors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            child: Icon(
                              Iconsax.add,
                              size: 24.sp,
                              color: theme.primaryColor.withOpacity(0.5),
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
                  color: theme.scaffoldBackgroundColor,
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
                if (nameController.text.isEmpty || selectedIconPath == null) {
                  Get.snackbar('Erro', 'Preencha todos os campos',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                // Validação do dia de fechamento
                final closingDay = int.tryParse(closingDayController.text);
                if (closingDay == null || closingDay < 1 || closingDay > 31) {
                  Get.snackbar(
                      'Erro', 'Informe o dia de fechamento entre 1 e 31',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white);
                  return;
                }

                // Converter o texto formatado em double
                final String rawLimit = limitController.text
                    .replaceAll('R\$', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.')
                    .trim();
                final double? parsedLimit = double.tryParse(rawLimit);

                final cardData = CardsModel(
                  id: widget.isEditing ? widget.card!.id : null,
                  name: nameController.text,
                  iconPath: selectedIconPath,
                  bankName: selectedBankName,
                  userId: widget.isEditing ? widget.card!.userId : null,
                  limit: parsedLimit,
                  closingDay: closingDay,
                );

                if (widget.isEditing) {
                  cardController.updateCard(cardData);
                } else {
                  cardController.addCard(cardData);
                }

                if (widget.fromOnboarding) {
                  Get.offAllNamed(Routes.CARD_SUCCESS);
                } else {
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
