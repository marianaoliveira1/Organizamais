// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';

class ResumePage extends StatelessWidget {
  final TransactionModel? transaction;

  const ResumePage({Key? key, this.transaction}) : super(key: key);

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.receita:
        return Colors.green;
      case TransactionType.despesa:
        return Colors.red;
      case TransactionType.transferencia:
        return Colors.grey;
    }
  }

  String _getTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.receita:
        return "Receita";
      case TransactionType.despesa:
        return "Despesa";
      case TransactionType.transferencia:
        return "Transferência";
    }
  }

  String _formatCurrency(String value) {
    // Tentativa de converter para double para formatação
    try {
      double numericValue = double.parse(value.replaceAll(',', '.'));
      return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(numericValue);
    } catch (e) {
      // Se não conseguir converter, retorna o valor original
      return "R\$ $value";
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Data não disponível";

    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr; // Retorna a string original se não conseguir formatar
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se não houver transação, exibe uma mensagem
    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Resumo da Transação"),
          backgroundColor: Colors.grey,
          foregroundColor: DefaultColors.white,
        ),
        body: Center(
          child: Text(
            "Nenhuma transação disponível para exibir",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Resumo da Transação"),
        backgroundColor: _getTypeColor(transaction!.type),
        foregroundColor: DefaultColors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    _getTypeText(transaction!.type),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(transaction!.type),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    _formatCurrency(transaction!.value),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(transaction!.type),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            _buildInfoItem("Descrição", transaction!.title),
            Divider(),
            if (transaction!.type != TransactionType.transferencia && transaction!.category != null) ...[
              _buildInfoItem("Categoria", "Categoria ${transaction!.category}"),
              Divider(),
            ],
            if (transaction!.type != TransactionType.transferencia && transaction!.paymentType != null) ...[
              _buildInfoItem(transaction!.type == TransactionType.receita ? "Recebido em" : "Pago com", transaction!.paymentType!),
              Divider(),
            ],
            _buildInfoItem("Data", _formatDate(transaction!.paymentDay)),
            Divider(),
            SizedBox(height: 40.h),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back(); // Voltar duas telas para ir à tela inicial
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  "Voltar para a tela inicial",
                  style: TextStyle(
                    color: DefaultColors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: DefaultColors.grey,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: DefaultColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
