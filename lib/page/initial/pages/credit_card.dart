import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/initial/pages/bank.dart';
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
  int? selectedIcon; // Ícone selecionado

  @override
  void dispose() {
    titleController.dispose();
    limitController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    if (selectedIcon == null) {
      Get.snackbar(
        'Atenção',
        'Por favor, selecione um ícone',
        backgroundColor: Colors.amber,
        colorText: DefaultColors.white,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Atenção',
        'Por favor, preencha o formulário corretamente',
        backgroundColor: Colors.amber,
        colorText: DefaultColors.white,
      );
      return;
    }

    try {
      final card = CardsModel(
        title: titleController.text,
        icon: selectedIcon!, // Agora o selectedIcon está sendo atualizado corretamente
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
              DefaultTitleTransaction(title: 'Nome do Cartão'),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Digite o nome do cartão',
                  hintStyle: TextStyle(fontSize: 12.sp, color: DefaultColors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(color: DefaultColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(color: DefaultColors.black),
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
              DefaultTitleTransaction(title: 'Escolha um ícone'),
              BankSelector(
                onBankSelected: (bank) {
                  setState(() {
                    selectedIcon = bank['id']; // Atualiza o ícone selecionado corretamente
                  });
                },
              ),
              SizedBox(height: 20.h),
              DefaultTitleTransaction(title: 'Limite do cartão'),
              TextFormField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Digite o limite do cartão',
                  hintStyle: TextStyle(fontSize: 12.sp, color: DefaultColors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(color: DefaultColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(color: DefaultColors.black),
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
                  padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.h),
                  decoration: BoxDecoration(
                    color: DefaultColors.green,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      'Adicionar Cartão',
                      style: TextStyle(fontSize: 12.sp, color: DefaultColors.white),
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

class BankSelector extends StatefulWidget {
  final Function(Map<String, dynamic>)? onBankSelected;

  const BankSelector({super.key, this.onBankSelected});

  @override
  State<BankSelector> createState() => _BankSelectorState();
}

class _BankSelectorState extends State<BankSelector> {
  Map<String, dynamic>? selectedBank;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BankSearchPage()),
          );

          if (result != null) {
            final selected = banks.firstWhere((bank) => bank['id'] == result);
            setState(() {
              selectedBank = selected;
            });

            if (widget.onBankSelected != null) {
              widget.onBankSelected!(selected);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            children: [
              if (selectedBank != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.asset(
                    selectedBank!['icon'],
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    selectedBank!['name'],
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ] else
                Expanded(
                  child: Text(
                    'Selecione o Ícone',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class BankSearchPage extends StatefulWidget {
  const BankSearchPage({super.key});

  @override
  State<BankSearchPage> createState() => _BankSearchPageState();
}

class _BankSearchPageState extends State<BankSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredBanks = List.from(banks);

  void _filterBanks(String query) {
    setState(() {
      filteredBanks = banks.where((bank) => bank['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text('Selecione o Banco'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterBanks,
              decoration: InputDecoration(
                hintText: 'Pesquisar banco...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ),
              itemCount: filteredBanks.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                    bottom: 10.h,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 6.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      14.r,
                    ),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        20.r,
                      ),
                      child: Image.asset(
                        filteredBanks[index]['icon'],
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      filteredBanks[index]['name']!,
                    ),
                    onTap: () {
                      Navigator.pop(context, filteredBanks[index]['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
