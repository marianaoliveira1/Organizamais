import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/color.dart';
import '../../../controller/card_controller.dart';

import 'payment_type_page.dart';

class PaymentTypeField extends StatefulWidget {
  final TextEditingController controller;

  const PaymentTypeField({
    super.key,
    required this.controller,
  });

  @override
  State<PaymentTypeField> createState() => _PaymentTypeFieldState();
}

class _PaymentTypeFieldState extends State<PaymentTypeField> {
  String? _selectedAssetPath;
  late final VoidCallback _controllerListener;

  // Mapeia textos conhecidos para ícones padrão, caso não venha um asset
  IconData? _mapTitleToIcon(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('pix')) return Icons.flash_on;
    if (normalized.contains('dinheiro')) return Icons.attach_money;
    if (normalized.contains('débito') || normalized.contains('debito')) {
      return Icons.credit_card;
    }
    if (normalized.contains('boleto')) return Icons.receipt_long;
    if (normalized.contains('vale')) return Icons.lunch_dining;
    if (normalized.contains('ted')) return Icons.swap_horiz;
    return Icons.payment;
  }

  @override
  void initState() {
    super.initState();
    // Listener para atualizar o ícone quando o texto mudar (ex.: edição)
    _controllerListener = () {
      final resolved = _resolveAssetForText(widget.controller.text);
      if (resolved != _selectedAssetPath) {
        setState(() {
          _selectedAssetPath = resolved;
        });
      }
    };
    widget.controller.addListener(_controllerListener);

    // Resolve o ícone inicial ao carregar a tela de edição
    _selectedAssetPath = _resolveAssetForText(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  String? _resolveAssetForText(String text) {
    final normalized = text.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    // 1) Tenta encontrar um cartão cadastrado com este nome
    try {
      final CardController cardController = Get.find<CardController>();
      for (final c in cardController.card) {
        final name = (c.name).trim().toLowerCase();
        if (name == normalized) {
          final path = c.iconPath;
          if (path != null && path.isNotEmpty) return path;
          break;
        }
      }
    } catch (_) {
      // Se o CardController não estiver disponível, ignora
    }

    // 2) Mapeia métodos padrão para os assets usados na seleção
    if (normalized.contains('pix')) return 'assets/icon-payment/pix.png';
    if (normalized.contains('dinheiro')) return 'assets/icon-payment/money.png';
    if (normalized.contains('débito') || normalized.contains('debito')) {
      return 'assets/icon-category/debito.png';
    }
    if (normalized.contains('boleto')) return 'assets/icon-payment/fatura.png';
    if (normalized.contains('vale')) {
      return 'assets/icon-payment/cartoes-de-credito.png';
    }
    if (normalized.contains('ted')) return 'assets/icon-payment/ted.png';

    // 3) Sem asset específico
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAsset =
        _selectedAssetPath != null && _selectedAssetPath!.isNotEmpty;

    return TextField(
      controller: widget.controller,
      readOnly: true,
      style: TextStyle(
        fontSize: 16.sp,
        color: theme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Selecione o tipo de pagamento",
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: DefaultColors.grey20,
          fontWeight: FontWeight.w500,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
        prefixIcon: SizedBox(
          width: 40.w,
          height: 40.h,
          child: Center(
            child: hasAsset
                ? Image.asset(
                    _selectedAssetPath!,
                    width: 22.w,
                    height: 22.h,
                  )
                : Icon(
                    _mapTitleToIcon(widget.controller.text),
                    color: DefaultColors.grey20,
                    size: 22.w,
                  ),
          ),
        ),
      ),
      onTap: () async {
        final result =
            await Get.to(() => PaymentTypePage(controller: widget.controller));
        if (result != null && result is Map) {
          final String? title = result['title'] as String?;
          final String? assetPath = result['assetPath'] as String?;
          if (title != null) {
            widget.controller.text = title;
          }
          setState(() {
            _selectedAssetPath = assetPath ?? _resolveAssetForText(title ?? '');
          });
        }
      },
    );
  }
}
