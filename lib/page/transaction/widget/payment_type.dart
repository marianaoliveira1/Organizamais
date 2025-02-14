import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/color.dart';

class PaymentTypeField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentTypeField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DefaultColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      isScrollControlled: true, // Permite que o modal ocupe mais espaço
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Ajusta conforme teclado
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Evita que a Column ocupe mais espaço do que precisa
              children: [
                Text(
                  'Selecione o método de pagamento',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                ListView(
                  shrinkWrap: true, // Evita overflow
                  physics: NeverScrollableScrollPhysics(), // Desativa rolagem dupla
                  children: [
                    _buildPaymentOption(
                      context,
                      'Dinheiro',
                      'assets/icon-payment/money.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'PIX',
                      'assets/icon-payment/pix.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'Boleto',
                      'assets/icon-payment/fatura.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'Criptomoedas',
                      'assets/icon-payment/cifrao.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'Vale Refeição',
                      'assets/icon-payment/cartoes-de-credito.png',
                      controller,
                    ),
                    _buildPaymentOption(
                      context,
                      'TED',
                      'assets/icon-payment/ted.png',
                      controller,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String assetPath,
    TextEditingController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: DefaultColors.background,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 4.h,
        horizontal: 10.w,
      ),
      margin: EdgeInsets.only(bottom: 14.h),
      child: ListTile(
        leading: Image.asset(
          assetPath,
          width: 22.w,
          height: 22.h,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          controller.text = title;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Selecione o tipo de pagamento",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      onTap: () => _showPaymentOptions(context),
    );
  }
}
