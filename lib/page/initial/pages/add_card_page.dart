import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
        backgroundColor: DefaultColors.background,
        title: Text(widget.isEditing ? 'Editar Cartão' : 'Criar Cartão'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTitleTransaction(title: "Nome do cartão"),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nome do Cartão',
                hintStyle: TextStyle(
                  color: DefaultColors.grey,
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: limitController,
              decoration: InputDecoration(
                labelText: 'Limite',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selectedIconPath != null
                      ? Row(
                          children: [
                            Image.asset(
                              selectedIconPath!,
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 8),
                            Text(selectedBankName ?? ''),
                          ],
                        )
                      : Text('Selecionar Ícone'),
                ],
              ),
              onPressed: () {
                Get.to(() => SelectIconPage(
                      onIconSelected: (path, name) {
                        setState(() {
                          selectedIconPath = path;
                          selectedBankName = name;
                        });
                      },
                    ));
              },
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.isEditing ? 'Atualizar Cartão' : 'Adicionar Cartão',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
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
