import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organizamais/page/initial/widget/finance_summary.dart';
import 'package:organizamais/page/initial/widget/fixed_accounts.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/card_controller.dart';
import '../../controller/fixed_accounts_controller.dart';
import '../../model/cards_model.dart';
import 'pages/bank.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FixedAccountsController());
    final CardController cardController = Get.put(CardController());

    return Scaffold(
      backgroundColor: DefaultColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20.w,
                horizontal: 20.h,
              ),
              child: Column(
                spacing: 20.h,
                children: [
                  FinanceSummaryWidget(),
                  DefaultWidgetFixedAccounts(),
                  CreditCardSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCardItem extends StatelessWidget {
  final CardsModel card;

  const CreditCardItem({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Encontra o banco correspondente ao ícone
    final bank = banks.firstWhere(
      (bank) => bank['id'] == card.iconPath,
      orElse: () => banks.first,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone do banco
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Image.asset(
              bank['icon'],
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          // Informações do cartão
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.bankName ?? 'Banco',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: DefaultColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Limite: R\$ ${card.limit}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: DefaultColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreditCardSection extends StatelessWidget {
  final CardController cardController = Get.find<CardController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget de Meus Cartões
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meus Cartões',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () {
                            Get.to(() => AddCardPage(
                                  isEditing: false,
                                ));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Obx(() {
                      // Verificamos se já temos cartões carregados
                      if (cardController.card.isEmpty) {
                        return Container(
                          height: 150,
                          alignment: Alignment.center,
                          child: Text('Nenhum cartão adicionado'),
                        );
                      } else {
                        return Container(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cardController.card.length,
                            itemBuilder: (context, index) {
                              final card = cardController.card[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => AddCardPage(
                                          isEditing: true,
                                          card: card,
                                        ));
                                  },
                                  child: Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (card.iconPath != null)
                                              Image.asset(
                                                card.iconPath!,
                                                width: 40,
                                                height: 40,
                                              ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                card.name,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          'Limite: R\$ ${card.limit.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.white, size: 20),
                                              constraints: BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                Get.to(() => AddCardPage(
                                                      isEditing: true,
                                                      card: card,
                                                    ));
                                              },
                                            ),
                                            SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.white, size: 20),
                                              constraints: BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text('Confirmar exclusão'),
                                                    content: Text('Tem certeza que deseja excluir o cartão ${card.name}?'),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('Cancelar'),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text('Excluir'),
                                                        onPressed: () {
                                                          cardController.deleteCard(card.id!);
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCardPage extends StatefulWidget {
  final bool isEditing;
  final CardsModel? card;

  const AddCardPage({
    Key? key,
    required this.isEditing,
    this.card,
  }) : super(key: key);

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
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Cartão' : 'Adicionar Cartão'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Cartão',
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

class SelectIconPage extends StatefulWidget {
  final Function(String, String) onIconSelected;

  const SelectIconPage({Key? key, required this.onIconSelected}) : super(key: key);

  @override
  _SelectIconPageState createState() => _SelectIconPageState();
}

class _SelectIconPageState extends State<SelectIconPage> {
  final searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, String>> bankIcons = [
    {
      'path': 'assets/icon-bank/abc-brasil.png',
      'name': 'ABC Brasil'
    },
    {
      'path': 'assets/icon-bank/agi.png',
      'name': 'AGI'
    },
    {
      'path': 'assets/icon-bank/amazon-pay.png',
      'name': 'Amazon Pay'
    },
    {
      'path': 'assets/icon-bank/american-express.png',
      'name': 'American Express'
    },
    {
      'path': 'assets/icon-bank/avenue.png',
      'name': 'Avenue'
    },
    {
      'path': 'assets/icon-bank/banco-agora.png',
      'name': 'Banco Ágora'
    },
    {
      'path': 'assets/icon-bank/banco-alfa.png',
      'name': 'Banco Alfa'
    },
    {
      'path': 'assets/icon-bank/banco-da-amazonia.png',
      'name': 'Banco da Amazônia'
    },
    {
      'path': 'assets/icon-bank/banco-daycoval.png',
      'name': 'Banco Daycoval'
    },
    {
      'path': 'assets/icon-bank/banco-do-brasil.png',
      'name': 'Banco do Brasil'
    },
    {
      'path': 'assets/icon-bank/banco-do-nordeste.png',
      'name': 'Banco do Nordeste'
    },
    {
      'path': 'assets/icon-bank/banco-mercantil.png',
      'name': 'Banco Mercantil'
    },
    {
      'path': 'assets/icon-bank/banco-modalmais.png',
      'name': 'Banco ModalMais'
    },
    {
      'path': 'assets/icon-bank/banco-pan.png',
      'name': 'Banco Pan'
    },
    {
      'path': 'assets/icon-bank/banese.png',
      'name': 'Banese'
    },
    {
      'path': 'assets/icon-bank/banestes.png',
      'name': 'Banestes'
    },
    {
      'path': 'assets/icon-bank/banpara.png',
      'name': 'Banpará'
    },
    {
      'path': 'assets/icon-bank/banrisul.png',
      'name': 'Banrisul'
    },
    {
      'path': 'assets/icon-bank/bari.png',
      'name': 'Bari'
    },
    {
      'path': 'assets/icon-bank/bdmg.png',
      'name': 'BDMG'
    },
    {
      'path': 'assets/icon-bank/bib.png',
      'name': 'BIB'
    },
    {
      'path': 'assets/icon-bank/bmg.png',
      'name': 'BMG'
    },
    {
      'path': 'assets/icon-bank/bndes.png',
      'name': 'BNDES'
    },
    {
      'path': 'assets/icon-bank/bradesco.png',
      'name': 'Bradesco'
    },
    {
      'path': 'assets/icon-bank/brb.png',
      'name': 'BRB'
    },
    {
      'path': 'assets/icon-bank/brde.png',
      'name': 'BRDE'
    },
    {
      'path': 'assets/icon-bank/bs2.png',
      'name': 'BS2'
    },
    {
      'path': 'assets/icon-bank/btg.png',
      'name': 'BTG'
    },
    {
      'path': 'assets/icon-bank/bv.png',
      'name': 'BV'
    },
    {
      'path': 'assets/icon-bank/c6.png',
      'name': 'C6 Bank'
    },
    {
      'path': 'assets/icon-bank/caixa.png',
      'name': 'Caixa'
    },
    {
      'path': 'assets/icon-bank/citi.png',
      'name': 'Citi'
    },
    {
      'path': 'assets/icon-bank/clear-corretora.png',
      'name': 'Clear Corretora'
    },
    {
      'path': 'assets/icon-bank/credisis.png',
      'name': 'Credisis'
    },
    {
      'path': 'assets/icon-bank/cresol.png',
      'name': 'Cresol'
    },
    {
      'path': 'assets/icon-bank/digi+.png',
      'name': 'Digi+'
    },
    {
      'path': 'assets/icon-bank/digio.png',
      'name': 'Digio'
    },
    {
      'path': 'assets/icon-bank/efi-bank.png',
      'name': 'EFI Bank'
    },
    {
      'path': 'assets/icon-bank/genial.png',
      'name': 'Genial'
    },
    {
      'path': 'assets/icon-bank/hsbc.png',
      'name': 'HSBC'
    },
    {
      'path': 'assets/icon-bank/icone-generico.png',
      'name': 'Genérico'
    },
    {
      'path': 'assets/icon-bank/inter.png',
      'name': 'Inter'
    },
    {
      'path': 'assets/icon-bank/ion.png',
      'name': 'Ion'
    },
    {
      'path': 'assets/icon-bank/itau.png',
      'name': 'Itaú'
    },
    {
      'path': 'assets/icon-bank/iti.png',
      'name': 'Iti'
    },
    {
      'path': 'assets/icon-bank/lar.png',
      'name': 'Lar'
    },
    {
      'path': 'assets/icon-bank/latam-pass.png',
      'name': 'Latam Pass'
    },
    {
      'path': 'assets/icon-bank/mercado-pago.png',
      'name': 'Mercado Pago'
    },
    {
      'path': 'assets/icon-bank/modal.png',
      'name': 'Modal'
    },
    {
      'path': 'assets/icon-bank/neon.png',
      'name': 'Neon'
    },
    {
      'path': 'assets/icon-bank/next.png',
      'name': 'Next'
    },
    {
      'path': 'assets/icon-bank/nomad.png',
      'name': 'Nomad'
    },
    {
      'path': 'assets/icon-bank/nubank.png',
      'name': 'Nubank'
    },
    {
      'path': 'assets/icon-bank/original.png',
      'name': 'Original'
    },
    {
      'path': 'assets/icon-bank/pagbank.png',
      'name': 'PagBank'
    },
    {
      'path': 'assets/icon-bank/paranabanco.png',
      'name': 'Paranabanco'
    },
    {
      'path': 'assets/icon-bank/pay-pal.png',
      'name': 'PayPal'
    },
    {
      'path': 'assets/icon-bank/pic-pay.png',
      'name': 'PicPay'
    },
    {
      'path': 'assets/icon-bank/rico.png',
      'name': 'Rico'
    },
    {
      'path': 'assets/icon-bank/safra.png',
      'name': 'Safra'
    },
    {
      'path': 'assets/icon-bank/santander.png',
      'name': 'Santander'
    },
    {
      'path': 'assets/icon-bank/shopee-pay.png',
      'name': 'Shopee Pay'
    },
    {
      'path': 'assets/icon-bank/sicoob.png',
      'name': 'Sicoob'
    },
    {
      'path': 'assets/icon-bank/sicredi.png',
      'name': 'Sicredi'
    },
    {
      'path': 'assets/icon-bank/sisprime.png',
      'name': 'SisPrime'
    },
    {
      'path': 'assets/icon-bank/sofisa.png',
      'name': 'Sofisa'
    },
    {
      'path': 'assets/icon-bank/stone.png',
      'name': 'Stone'
    },
    {
      'path': 'assets/icon-bank/stonex.png',
      'name': 'StoneX'
    },
    {
      'path': 'assets/icon-bank/topazio.png',
      'name': 'Topázio'
    },
    {
      'path': 'assets/icon-bank/toro.png',
      'name': 'Toro'
    },
    {
      'path': 'assets/icon-bank/tudo-azul.png',
      'name': 'TudoAzul'
    },
    {
      'path': 'assets/icon-bank/unicred.png',
      'name': 'Unicred'
    },
    {
      'path': 'assets/icon-bank/vivacredi.png',
      'name': 'Vivacredi'
    },
    {
      'path': 'assets/icon-bank/western-union.png',
      'name': 'Western Union'
    },
    {
      'path': 'assets/icon-bank/will-bank.png',
      'name': 'Will Bank'
    },
    {
      'path': 'assets/icon-bank/wise.png',
      'name': 'Wise'
    },
    {
      'path': 'assets/icon-bank/xp.png',
      'name': 'XP'
    },
  ];

  List<Map<String, String>> get filteredBankIcons {
    if (searchQuery.isEmpty) {
      return bankIcons;
    }
    return bankIcons.where((bank) => bank['name']!.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Ícone'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Pesquisar banco',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredBankIcons.isEmpty
                ? Center(
                    child: Text('Nenhum banco encontrado'),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredBankIcons.length,
                    itemBuilder: (context, index) {
                      final bank = filteredBankIcons[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onIconSelected(bank['path']!, bank['name']!);
                          Get.back();
                        },
                        child: Card(
                          elevation: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                bank['path']!,
                                width: 48,
                                height: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                bank['name']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
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

class DefaultWidgetFixedAccounts extends StatelessWidget {
  const DefaultWidgetFixedAccounts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contas fixas",
                style: TextStyle(
                  color: DefaultColors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed("/fixed-accounts");
                },
                child: Icon(
                  Icons.add,
                  size: 16.sp,
                  color: DefaultColors.grey,
                ),
              ),
            ],
          ),
          FixedAccounts(
            fixedAccounts: Get.find<FixedAccountsController>().fixedAccounts,
          ),
        ],
      ),
    );
  }
}
