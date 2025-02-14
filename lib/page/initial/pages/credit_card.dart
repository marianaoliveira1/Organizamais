import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/utils/color.dart';
import '../../../controller/card_controller.dart';
import '../../../model/cards_model.dart';
import '../../transaction/widget/title_transaction.dart';

class CreditCardPage extends StatefulWidget {
  const CreditCardPage({super.key});

  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final CardController _cardController = Get.find<CardController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController limitController = TextEditingController();
  int? selectedIcon;

  @override
  void dispose() {
    titleController.dispose();
    limitController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    if (_formKey.currentState!.validate() && selectedIcon != null) {
      try {
        final card = CardsModel(
          title: titleController.text,
          icon: selectedIcon!,
          limit: limitController.text,
        );

        await _cardController.addCard(card);
        Get.back();
      } catch (e) {
        Get.snackbar(
          'Erro',
          'Ocorreu um erro ao adicionar o cartão',
          backgroundColor: Colors.red,
          colorText: DefaultColors.white,
        );
      }
    } else if (selectedIcon == null) {
      Get.snackbar(
        'Atenção',
        'Por favor, selecione um ícone para o cartão',
        backgroundColor: Colors.amber,
        colorText: DefaultColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.background,
      appBar: AppBar(
        backgroundColor: DefaultColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.h,
          vertical: 20.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTitleTransaction(
                title: 'Nome do Cartão',
              ),
              TextFormField(
                controller: titleController,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite o nome do cartão';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              DefaultTitleTransaction(
                title: 'Escolha um ícone',
              ),
              InkWell(
                onTap: () async {
                  final result = await Get.toNamed("/bank");
                  if (result != null) {
                    setState(() {
                      selectedIcon = result;
                    });
                  }
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
                      SizedBox(width: 10.w),
                      Text(
                        selectedIcon != null ? 'Ícone selecionado' : 'Selecione um icone',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DefaultColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              DefaultTitleTransaction(
                title: 'Limite do cartão',
              ),
              TextFormField(
                controller: limitController,
                keyboardType: TextInputType.number,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite o limite do cartão';
                  }
                  return null;
                },
              ),
              Spacer(),
              InkWell(
                onTap: _saveCard,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
