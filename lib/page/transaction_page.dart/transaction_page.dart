// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:organizamais/page/transaction_page.dart/pages/%20%20category.dart';
import 'package:organizamais/utils/color.dart';

import '../../controller/transaction_controller.dart';
import '../../model/transaction_model.dart';
import 'widget/text_field_transaction.dart';
import 'widget/title_transaction.dart';

class TransactionPage extends StatefulWidget {
  final TransactionType transactionType;

  const TransactionPage({super.key, required this.transactionType});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int? categoryId;
  String paymentMethod = '';
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.white,
      appBar: AppBar(
        backgroundColor: DefaultColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView para evitar overflow
        padding: EdgeInsets.all(16),
        child: Form(
          // Envolva o conteúdo com um Form
          key: _formKey, // Defina a chave do formulário
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTitleTransaction(title: 'Valor'),
              DefaultTextFieldTransaction(
                hintText: '0,00',
                controller: valueController,
                icon: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
              ),
              SizedBox(height: 16.h),

              DefaultTitleTransaction(title: 'Título'),
              DefaultTextFieldTransaction(
                hintText: 'Ex: Compra de mercado',
                controller: titleController,
                keyboardType: TextInputType.text,
                // validator: (value) { // Validação do campo Título
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
              ),
              SizedBox(height: 16.h),

              DefaultTitleTransaction(title: "Categoria"),
              DefaultButtonSelectCategory(
                selectedCategory: categoryId,
                onTap: (category) {
                  setState(() {
                    categoryId = category;
                  });
                },
              ),
              SizedBox(height: 16.h),

              DefaultTitleTransaction(title: "Data"),
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
                  padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: TextStyle(color: DefaultColors.grey, fontSize: 14.sp),
                      ),
                      const Icon(Iconsax.calendar_1),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              _buildPaymentSection(), // Seção de pagamento condicional

              SizedBox(height: 16.h),

              // Botões Salvar e Cancelar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context), // Ação de cancelar
                    child: Container(
                      margin: EdgeInsets.only(top: 20.h),
                      padding: EdgeInsets.all(16.h),
                      decoration: BoxDecoration(
                        color: DefaultColors.grey,
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      child: Center(
                        child: Text(
                          "Cancelar",
                          style: TextStyle(color: DefaultColors.black, fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // Valida o formulário
                        TransactionModel newTransaction = TransactionModel(
                          id: '',
                          type: widget.transactionType,
                          description: titleController.text,
                          category: categories.firstWhere((element) => element['id'] == categoryId)['name'],
                          paymentMethod: paymentMethod,
                          date: selectedDate,
                          amount: double.parse(valueController.text),
                          isFixed: false,
                          isInstallment: false,
                        );
                        Get.find<TransactionController>().addTransaction(newTransaction);
                        Get.back();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20.h),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: DefaultColors.black,
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      child: Center(
                        child: Text(
                          "Salvar",
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    switch (widget.transactionType) {
      case TransactionType.despesa:
        return _buildPaymentOptions("Pago com");
      case TransactionType.receita:
        return _buildPaymentOptions("Recebido em");
      case TransactionType.transferencia:
        return Column(
          children: [
            _buildPaymentOptions("Conta Origem"),
            SizedBox(height: 16.h),
            _buildPaymentOptions("Conta Destino"),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildPaymentOptions(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTitleTransaction(title: title),
        DropdownButton<String>(
          value: paymentMethod.isEmpty ? null : paymentMethod,
          hint: const Text('Selecione'),
          items: <String>[
            'Opção 1',
            'Opção 2',
            'Opção 3'
          ] // Substitua pelas suas opções
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              paymentMethod = newValue!;
            });
          },
        ),
      ],
    );
  }
}

class DefaultButtonSelectCategory extends StatelessWidget {
  const DefaultButtonSelectCategory({
    super.key,
    required this.onTap,
    required this.selectedCategory,
  });

  final Function(int?) onTap;
  final int? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var category = await Get.to(
          () => Category(),
        );
        onTap(category);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.h,
          vertical: 15.h,
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
      ),
    );
  }
}

// // ignore_for_file: library_private_types_in_public_api

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:organizamais/utils/color.dart';

// import 'pages/  category.dart';
// import 'widget/text_field_transaction.dart';
// import 'widget/title_transaction.dart';

// class TransactionPage extends StatefulWidget {
//   final String? type;
//   final String? transactionType;

//   const TransactionPage({
//     super.key,
//     this.type,
//     this.transactionType,
//   });

//   @override
//   _TransactionPageState createState() => _TransactionPageState();
// }

// class _TransactionPageState extends State<TransactionPage> {
//   DateTime selectedDate = DateTime.now();
//   final TextEditingController valueController = TextEditingController();
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   int? categoryId;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: DefaultColors.white,
//       appBar: AppBar(
//         backgroundColor: DefaultColors.white,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               DefaultTitleTransaction(
//                 title: 'Valor',
//               ),
//               DefaultTextFieldTransaction(
//                 hintText: '0,00',
//                 controller: valueController,
//                 icon: Icon(
//                   Icons.attach_money,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(
//                 height: 16.h,
//               ),
//               DefaultTitleTransaction(
//                 title: 'Título',
//               ),
//               DefaultTextFieldTransaction(
//                 hintText: 'Ex: Compra de mercado',
//                 controller: titleController,
//                 keyboardType: TextInputType.text,
//               ),
//               SizedBox(
//                 height: 16.h,
//               ),
//               DefaultTitleTransaction(
//                 title: "Categoria",
//               ),
//               DefaultButtonSelectCategory(
//                 selectedCategory: categoryId,
//                 onTap: (category) {
//                   setState(() {
//                     categoryId = category;
//                   });
//                 },
//               ),
//               SizedBox(
//                 height: 16.h,
//               ),
//               DefaultTitleTransaction(
//                 title: "Data",
//               ),
//               InkWell(
//                 onTap: () async {
//                   final DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: selectedDate,
//                     firstDate: DateTime(2015, 8),
//                     lastDate: DateTime(2101),
//                   );
//                   if (picked != null && picked != selectedDate) {
//                     setState(() {
//                       selectedDate = picked;
//                     });
//                   }
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.h,
//                     vertical: 15.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(
//                       14.r,
//                     ),
//                     border: Border.all(
//                       color: Colors.grey,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "dd/mm/aaaa",
//                         style: TextStyle(
//                           color: DefaultColors.grey,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                       Icon(
//                         Iconsax.calendar_1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               //de for despesas: pago com
//               //se for receita recebi em
//               //se for transfrencia conta origem - conta destino e com + na frente
//               DefaultTitleTransaction(title: "Forma de pagamento"),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     //button save
//                     child: Container(
//                       margin: EdgeInsets.only(top: 20.h),
//                       padding: EdgeInsets.all(16.h),
//                       decoration: BoxDecoration(
//                         color: DefaultColors.grey,
//                         borderRadius: BorderRadius.circular(
//                           32.r,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Cancelar",
//                           style: TextStyle(
//                             color: DefaultColors.black,
//                             fontSize: 16.sp,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     //button save
//                     child: Container(
//                       margin: EdgeInsets.only(top: 20.h),
//                       padding: EdgeInsets.symmetric(
//                         vertical: 16.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: DefaultColors.black,
//                         borderRadius: BorderRadius.circular(
//                           32.r,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Salvar",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16.sp,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DefaultButtonSelectCategory extends StatelessWidget {
//   const DefaultButtonSelectCategory({
//     super.key,
//     required this.onTap,
//     required this.selectedCategory,
//   });

//   final Function(int?) onTap;
//   final int? selectedCategory;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () async {
//         var category = await Get.to(
//           () => Category(),
//         );
//         onTap(category);
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: 10.h,
//           vertical: 15.h,
//         ),
//         decoration: BoxDecoration(
//           color: DefaultColors.greyLight,
//           borderRadius: BorderRadius.circular(
//             14.r,
//           ),
//           border: Border.all(
//             color: Colors.grey,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             selectedCategory != null
//                 ? Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: DefaultColors.white,
//                         child: Image.asset(
//                           categories.firstWhere((element) => element['id'] == selectedCategory)['icon'],
//                           width: 20.w,
//                           height: 20.h,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10.w,
//                       ),
//                       Text(
//                         categories.firstWhere((element) => element['id'] == selectedCategory)['name'],
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: DefaultColors.black,
//                         ),
//                       ),
//                     ],
//                   )
//                 : Text("Selecione"),
//           ],
//         ),
//       ),
//     );
//   }
// }
