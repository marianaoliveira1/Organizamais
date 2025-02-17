// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:organizamais/page/initial/pages/bank.dart';
// import 'package:organizamais/utils/color.dart';
// import '../../../controller/card_controller.dart';
// import '../../../model/cards_model.dart';
// import '../../transaction/widget/title_transaction.dart';

// class CreditCardPage extends StatefulWidget {
//   final CardsModel? card;

//   const CreditCardPage({super.key, this.card});

//   @override
//   State<CreditCardPage> createState() => _CreditCardPageState();
// }

// class _CreditCardPageState extends State<CreditCardPage> {
//   final _formKey = GlobalKey<FormState>();
//   final CardController _cardController = Get.find<CardController>();
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController limitController = TextEditingController();
//   int? selectedIcon;

//   @override
//   void initState() {
//     super.initState();

//     // Se estiver editando, carregar os dados do cartão
//     if (widget.card != null) {
//       titleController.text = widget.card!.bankName ?? '';
//       limitController.text = widget.card?.limit?.toString() ?? '';
//       selectedIcon = (widget.card!.iconPath ?? 0) as int?;
//     }
//   }

//   @override
//   void dispose() {
//     titleController.dispose();
//     limitController.dispose();
//     super.dispose();
//   }

//   void _saveCard() async {
//     if (selectedIcon == null) {
//       Get.snackbar(
//         'Atenção',
//         'Por favor, selecione um ícone',
//         backgroundColor: Colors.amber,
//         colorText: DefaultColors.white,
//       );
//       return;
//     }

//     if (!_formKey.currentState!.validate()) {
//       Get.snackbar(
//         'Atenção',
//         'Por favor, preencha o formulário corretamente',
//         backgroundColor: Colors.amber,
//         colorText: DefaultColors.white,
//       );
//       return;
//     }

//     try {
//       final card = CardsModel(
//         id: widget.card?.id ?? '', // Se for edição, mantém o ID
//         bankName: titleController.text,
//         iconPath: selectedIcon!.toString(),
//         limit: double.tryParse(limitController.text),
//       );

//       if (widget.card == null) {
//         await _cardController.addCard(card);
//       } else {
//         await _cardController.updateCard(card);
//       }

//       Get.offAllNamed('/home');
//     } catch (e) {
//       Get.snackbar(
//         'Erro',
//         'Ocorreu um erro ao salvar o cartão',
//         backgroundColor: Colors.red,
//         colorText: DefaultColors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: DefaultColors.background,
//       appBar: AppBar(
//         backgroundColor: DefaultColors.background,
//         elevation: 0,
//         actions: [
//           if (widget.card != null)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.red),
//               onPressed: _deleteCard, // Chama o método para excluir
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               DefaultTitleTransaction(title: 'Nome do Cartão'),
//               TextFormField(
//                 controller: titleController,
//                 decoration: InputDecoration(
//                   hintText: 'Digite o nome do cartão',
//                   hintStyle: TextStyle(fontSize: 12.sp, color: DefaultColors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5.r),
//                     borderSide: BorderSide(color: DefaultColors.grey),
//                   ),
//                 ),
//                 validator: (value) => value!.isEmpty ? 'Digite o nome do cartão' : null,
//               ),
//               SizedBox(height: 20.h),
//               DefaultTitleTransaction(title: 'Escolha um ícone'),
//               BankSelector(
//                 initialBank: selectedIcon != null
//                     ? {
//                         'id': selectedIcon
//                       }
//                     : null,
//                 onBankSelected: (bank) {
//                   setState(() {
//                     selectedIcon = bank['id'];
//                   });
//                 },
//               ),
//               SizedBox(height: 20.h),
//               DefaultTitleTransaction(title: 'Limite do cartão'),
//               TextFormField(
//                 controller: limitController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: 'Digite o limite do cartão',
//                   hintStyle: TextStyle(fontSize: 12.sp, color: DefaultColors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5.r),
//                     borderSide: BorderSide(color: DefaultColors.grey),
//                   ),
//                 ),
//                 validator: (value) => value!.isEmpty ? 'Digite o limite do cartão' : null,
//               ),
//               Spacer(),
//               InkWell(
//                 onTap: _saveCard,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.h),
//                   decoration: BoxDecoration(
//                     color: DefaultColors.green,
//                     borderRadius: BorderRadius.circular(14.r),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.card == null ? 'Adicionar Cartão' : 'Atualizar Cartão',
//                       style: TextStyle(fontSize: 12.sp, color: DefaultColors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _deleteCard() async {
//     try {
//       await _cardController.deleteCard(widget.card!.id!);
//       Get.offAllNamed('/home');
//     } catch (e) {
//       Get.snackbar(
//         'Erro',
//         'Erro ao excluir o cartão',
//         backgroundColor: Colors.red,
//         colorText: DefaultColors.white,
//       );
//     }
//   }
// }

// class BankSelector extends StatefulWidget {
//   final Map<String, dynamic>? initialBank;
//   final Function(Map<String, dynamic>)? onBankSelected;

//   const BankSelector({
//     super.key,
//     this.onBankSelected,
//     this.initialBank,
//   });

//   @override
//   State<BankSelector> createState() => _BankSelectorState();
// }

// class _BankSelectorState extends State<BankSelector> {
//   Map<String, dynamic>? selectedBank;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       child: InkWell(
//         onTap: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => BankSearchPage()),
//           );

//           if (result != null) {
//             final selected = banks.firstWhere((bank) => bank['id'] == result);
//             setState(() {
//               selectedBank = selected;
//             });

//             if (widget.onBankSelected != null) {
//               widget.onBankSelected!(selected);
//             }
//           }
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14.r),
//             border: Border.all(color: Colors.grey.shade300, width: 1),
//           ),
//           child: Row(
//             children: [
//               if (selectedBank != null) ...[
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(20.r),
//                   child: Image.asset(
//                     selectedBank!['icon'],
//                     width: 30,
//                     height: 30,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Text(
//                     selectedBank!['name'],
//                     style: TextStyle(fontSize: 16, color: Colors.black87),
//                   ),
//                 ),
//               ] else
//                 Expanded(
//                   child: Text(
//                     'Selecione o Ícone',
//                     style: TextStyle(fontSize: 16, color: Colors.black54),
//                   ),
//                 ),
//               Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class BankSearchPage extends StatefulWidget {
//   const BankSearchPage({super.key});

//   @override
//   State<BankSearchPage> createState() => _BankSearchPageState();
// }

// class _BankSearchPageState extends State<BankSearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> filteredBanks = List.from(banks);

//   void _filterBanks(String query) {
//     setState(() {
//       filteredBanks = banks.where((bank) => bank['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.grey[100],
//         title: Text('Selecione o Banco'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(20),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _filterBanks,
//               decoration: InputDecoration(
//                 hintText: 'Pesquisar banco...',
//                 prefixIcon: Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14.r),
//                   borderSide: BorderSide(color: Colors.blue),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.symmetric(
//                 horizontal: 20.w,
//               ),
//               itemCount: filteredBanks.length,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: EdgeInsets.only(
//                     bottom: 10.h,
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     vertical: 10.h,
//                     horizontal: 6.w,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(
//                       14.r,
//                     ),
//                   ),
//                   child: ListTile(
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(
//                         20.r,
//                       ),
//                       child: Image.asset(
//                         filteredBanks[index]['icon'],
//                         width: 40,
//                         height: 40,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     title: Text(
//                       filteredBanks[index]['name']!,
//                     ),
//                     onTap: () {
//                       Navigator.pop(context, filteredBanks[index]['id']);
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
