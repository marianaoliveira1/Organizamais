// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

class MonthSelectorResume extends StatefulWidget {
  final RxString selectedMonth; // Formato: "Mês/AAAA"
  final int initialIndex; // Índice inicial na lista (0..23)
  final bool centerCurrentMonth; // Centralizar o mês atual

  const MonthSelectorResume({
    super.key,
    required this.selectedMonth,
    this.initialIndex = 0,
    this.centerCurrentMonth = true,
  });

  @override
  State<MonthSelectorResume> createState() => _MonthSelectorResumeState();
}

class _MonthSelectorResumeState extends State<MonthSelectorResume> {
  late ScrollController _scrollController;
  final List<String> _items = []; // Ex.: "Setembro/2025"
  int _scrollRetries = 0;
  bool _didIntroScroll = false;
  final Map<int, GlobalKey> _itemKeys = {};

  List<String> _buildMonthYearOptions() {
    // Lista fixa solicitada: 2025 a 2030
    final List<int> years = [2025, 2026, 2027, 2028, 2029, 2030];
    const List<String> months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    final List<String> result = [];
    for (final y in years) {
      for (final m in months) {
        result.add('$m/$y');
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _items.clear();
    _items.addAll(_buildMonthYearOptions());

    // Centralizar o mês atual após a construção do widget
    if (widget.centerCurrentMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Determinar índice do mês atual
        final now = DateTime.now();
        const List<String> months = [
          'Janeiro',
          'Fevereiro',
          'Março',
          'Abril',
          'Maio',
          'Junho',
          'Julho',
          'Agosto',
          'Setembro',
          'Outubro',
          'Novembro',
          'Dezembro'
        ];
        final String currentLabel = '${months[now.month - 1]}/${now.year}';
        final int currentIndex = _items.indexOf(currentLabel);
        final int target = currentIndex >= 0
            ? currentIndex
            : (_items.isNotEmpty ? 0 : widget.initialIndex);

        // Definir mês selecionado e centralizar
        if (_items.isNotEmpty) {
          widget.selectedMonth.value = _items[target];
          await _centerWithRetries(target);
        }
      });
    } else {
      // Se não for para centralizar, garanta ao menos que o valor inicial é válido
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final now = DateTime.now();
        const List<String> months = [
          'Janeiro',
          'Fevereiro',
          'Março',
          'Abril',
          'Maio',
          'Junho',
          'Julho',
          'Agosto',
          'Setembro',
          'Outubro',
          'Novembro',
          'Dezembro'
        ];
        final String currentLabel = '${months[now.month - 1]}/${now.year}';
        if (!_items.contains(widget.selectedMonth.value) && _items.isNotEmpty) {
          final int idx = _items.indexOf(currentLabel);
          final int safeIdx = idx >= 0 ? idx : 0;
          widget.selectedMonth.value = _items[safeIdx];
        }
      });
    }
  }

  Future<void> _centerWithRetries(int itemIndex) async {
    // Tenta centralizar usando ensureVisible, fazendo um pré-scroll proporcional
    // para forçar a construção do item quando necessário.
    int tries = 0;
    while (tries < 6) {
      final key = _itemKeys[itemIndex];
      if (key != null && key.currentContext != null) {
        await Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
        _didIntroScroll = true;
        return;
      }
      if (_scrollController.hasClients && _items.length > 1) {
        try {
          if (!_scrollController.position.hasContentDimensions) {
            continue;
          }
          final double fraction = itemIndex / (_items.length - 1);
          final double maxScroll = _scrollController.position.maxScrollExtent;
          final double target = (maxScroll * fraction).clamp(0.0, maxScroll);
          _scrollController.jumpTo(target);
        } catch (_) {
          // Se houver erro ao acessar position, continuar tentando
        }
      }
      tries += 1;
      await Future.delayed(const Duration(milliseconds: 60));
    }
    // Fallback final
    await _centerOnIndex(itemIndex);
  }

  void _scrollToIndex(int itemIndex) {
    // Estimar a posição do mês para centralizar
    // Isso depende do tamanho do seu item. Ajuste o valor 80.w conforme necessário
    final double itemWidth = 78.w;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset =
        itemIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);
    if (!_scrollController.hasClients) {
      if (_scrollRetries < 4) {
        _scrollRetries += 1;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToIndex(itemIndex));
      }
      return;
    }

    // Verificar se position está disponível de forma segura
    try {
      if (!_scrollController.position.hasContentDimensions ||
          _scrollController.position.maxScrollExtent == 0) {
        if (_scrollRetries < 4) {
          _scrollRetries += 1;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToIndex(itemIndex));
        }
        return;
      }
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double scrollPosition = offset.clamp(0.0, maxScroll);
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (_) {
      // Se houver erro ao acessar position, tentar novamente se ainda houver tentativas
      if (_scrollRetries < 4) {
        _scrollRetries += 1;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToIndex(itemIndex));
      }
    }
  }

  Future<void> _introScrollToIndex(int itemIndex) async {
    if (_didIntroScroll) {
      _scrollToIndex(itemIndex);
      return;
    }
    if (!_scrollController.hasClients) {
      if (_scrollRetries < 8) {
        _scrollRetries += 1;
        await Future.delayed(const Duration(milliseconds: 60));
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _introScrollToIndex(itemIndex));
      }
      return;
    }
    _didIntroScroll = true;
    final double itemWidth = 78.w;
    final double screenWidth = MediaQuery.of(context).size.width;
    try {
      _scrollController.jumpTo(0);
    } catch (_) {}
    for (int i = 0; i <= itemIndex; i++) {
      // Verificar se o widget ainda está montado
      if (!mounted) return;

      // Verificar se o controller ainda tem clientes antes de acessar position
      if (!_scrollController.hasClients) {
        break;
      }

      // Verificar se position está disponível e tem dimensões
      try {
        if (!_scrollController.position.hasContentDimensions) {
          break;
        }
      } catch (_) {
        // Se position não estiver disponível, sair do loop
        break;
      }

      // Acessar position de forma segura
      try {
        final double offset =
            i * itemWidth - (screenWidth / 2) + (itemWidth / 2);
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double scrollPosition = offset.clamp(0.0, maxScroll);
        await _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        );
      } catch (_) {
        // Se houver erro ao acessar position ou animar, sair do loop
        break;
      }
    }
  }

  Future<void> _centerOnIndex(int itemIndex) async {
    final key = _itemKeys[itemIndex];
    if (key != null && key.currentContext != null) {
      await Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _didIntroScroll = true;
      return;
    }
    // Fallback
    await _introScrollToIndex(itemIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      width: double.infinity,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final bool isSelected = widget.selectedMonth.value == _items[index];
            return GestureDetector(
              onTap: () {
                widget.selectedMonth.value = _items[index];
                _centerWithRetries(index);
              },
              child: Container(
                key: _itemKeys.putIfAbsent(index, () => GlobalKey()),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? DefaultColors.green
                        : DefaultColors.grey.withOpacity(
                            0.3,
                          ),
                  ),
                ),
                child: Center(
                  child: Text(
                    _items[index],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : DefaultColors.grey,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
