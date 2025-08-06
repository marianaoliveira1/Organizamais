// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

class MonthSelectorResume extends StatefulWidget {
  final RxString selectedMonth;
  final int initialMonth; // Mês inicial (0-11)
  final bool centerCurrentMonth; // Centralizar o mês atual

  const MonthSelectorResume({
    super.key,
    required this.selectedMonth,
    this.initialMonth = 0,
    this.centerCurrentMonth = false,
  });

  @override
  State<MonthSelectorResume> createState() => _MonthSelectorResumeState();
}

class _MonthSelectorResumeState extends State<MonthSelectorResume> {
  late ScrollController _scrollController;
  final List<String> _months = [
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Centralizar o mês atual após a construção do widget
    if (widget.centerCurrentMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMonth(widget.initialMonth);
      });
    }
  }

  void _scrollToMonth(int monthIndex) {
    // Estimar a posição do mês para centralizar
    // Isso depende do tamanho do seu item. Ajuste o valor 80.w conforme necessário
    final double itemWidth = 78.w;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset =
        monthIndex * itemWidth - (screenWidth / 2) + (itemWidth / 2);

    // Limitar o scroll para não ir além dos limites
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double scrollPosition = offset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
        itemCount: _months.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final bool isSelected =
                widget.selectedMonth.value == _months[index];
            return GestureDetector(
              onTap: () {
                widget.selectedMonth.value = _months[index];
              },
              child: Container(
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
                    _months[index],
                    style: TextStyle(
                      fontSize: 11.sp,
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
