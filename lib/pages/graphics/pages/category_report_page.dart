import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/controller/transaction_controller.dart';
import 'package:organizamais/model/transaction_model.dart';
import 'package:organizamais/utils/color.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../transaction/pages/category_page.dart';

class CategoryReportPage extends StatefulWidget {
  final String selectedMonth;
  final bool selectionMode;
  final Set<int>? initialSelected;

  const CategoryReportPage(
      {super.key,
      required this.selectedMonth,
      this.selectionMode = false,
      this.initialSelected});

  @override
  State<CategoryReportPage> createState() => _CategoryReportPageState();
}

class _CategoryReportPageState extends State<CategoryReportPage> {
  late Set<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<int>.from(widget.initialSelected ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    final TransactionController controller = Get.find<TransactionController>();

    final int currentYear = DateTime.now().year;
    final int currentMonthIndex = widget.selectedMonth.isEmpty
        ? DateTime.now().month
        : (getAllMonths().indexOf(widget.selectedMonth) + 1);

    final DateTime currentStart = DateTime(currentYear, currentMonthIndex, 1);
    final int lastDayCurrent =
        DateTime(currentYear, currentMonthIndex + 1, 0).day;
    final int endDayCurrent = DateTime.now().month == currentMonthIndex
        ? DateTime.now().day
        : lastDayCurrent;
    final DateTime currentEnd =
        DateTime(currentYear, currentMonthIndex, endDayCurrent, 23, 59, 59);

    final int prevMonth = currentMonthIndex == 1 ? 12 : currentMonthIndex - 1;
    final int prevYear = currentMonthIndex == 1 ? currentYear - 1 : currentYear;
    final DateTime prevStart = DateTime(prevYear, prevMonth, 1);
    final int lastDayPrev = DateTime(prevYear, prevMonth + 1, 0).day;
    final int prevEndDay =
        endDayCurrent > lastDayPrev ? lastDayPrev : endDayCurrent;
    final DateTime prevEnd =
        DateTime(prevYear, prevMonth, prevEndDay, 23, 59, 59);

    final Map<int, double> currentByCategory = _sumByCategory(
      controller.transaction,
      currentStart,
      currentEnd,
    );
    final Map<int, double> prevByCategory = _sumByCategory(
      controller.transaction,
      prevStart,
      prevEnd,
    );

    final Set<int> allCategories = {
      ...currentByCategory.keys,
      ...prevByCategory.keys,
    };

    final List<_CategoryDiff> diffs = allCategories.map((categoryId) {
      final double current = currentByCategory[categoryId] ?? 0.0;
      final double previous = prevByCategory[categoryId] ?? 0.0;
      final double diff = current - previous;
      double? percent;
      String? badge; // 'Novo' or 'Inativa'

      if (previous == 0 && current > 0) {
        badge = 'Nova no mês';
      } else if (previous > 0 && current == 0) {
        badge = 'Não usada';
        percent = -100.0;
      } else if (previous != 0) {
        percent = ((current - previous) / previous.abs()) * 100.0;
      }

      return _CategoryDiff(
        categoryId: categoryId,
        current: current,
        previous: previous,
        diff: diff,
        percent: percent,
        badge: badge,
      );
    }).toList()
      ..sort((a, b) => b.diff.abs().compareTo(a.diff.abs()));

    final int newCount = diffs.where((d) => d.badge == 'Nova no mês').length;
    final int unusedCount = diffs.where((d) => d.badge == 'Não usada').length;

    if (widget.selectionMode) {
      final List<int> usedCategories = currentByCategory.keys.toList()..sort();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Selecione as categorias'),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 20.h),
              Expanded(
                child: usedCategories.isEmpty
                    ? Center(
                        child: Text(
                          'Sem categorias para selecionar neste mês.',
                          style: TextStyle(
                            color: DefaultColors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: usedCategories.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: DefaultColors.grey.withOpacity(0.2),
                        ),
                        itemBuilder: (context, index) {
                          final int catId = usedCategories[index];
                          final info = findCategoryById(catId);
                          final String name =
                              info?['name'] ?? 'Categoria $catId';
                          final Color color =
                              info?['color'] ?? theme.primaryColor;
                          final String? iconPath = info?['icon'];
                          final bool isSelected = _tempSelected.contains(catId);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _tempSelected.remove(catId);
                                } else {
                                  _tempSelected.add(catId);
                                }
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: iconPath != null
                                        ? Image.asset(iconPath,
                                            width: 18.w, height: 18.h)
                                        : Icon(Icons.category,
                                            color: color, size: 18.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: theme.primaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _tempSelected.add(catId);
                                        } else {
                                          _tempSelected.remove(catId);
                                        }
                                      });
                                    },
                                    activeColor: DefaultColors.green,
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
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(_tempSelected);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'Ver resultado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório por categoria'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Text(
              "Variação em relação ao dia equivalente do mês anterior",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: DefaultColors.grey,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.fiber_new,
                  label: 'Novas: $newCount',
                  color: DefaultColors.green,
                ),
                SizedBox(width: 8.w),
                _InfoChip(
                  icon: Icons.block,
                  label: 'Não usadas: $unusedCount',
                  color: DefaultColors.grey,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: diffs.isEmpty
                  ? Center(
                      child: Text(
                        'Sem dados para este período.',
                        style: TextStyle(
                          color: DefaultColors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: diffs.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final d = diffs[index];
                        final info = findCategoryById(d.categoryId);
                        final String name =
                            info?['name'] ?? 'Categoria ${d.categoryId}';
                        final Color color =
                            info?['color'] ?? theme.primaryColor;
                        final String? iconPath = info?['icon'];

                        final bool decreased = d.diff < 0; // despesas caíram
                        final Color diffColor = decreased
                            ? DefaultColors.green
                            : (d.diff > 0
                                ? DefaultColors.red
                                : DefaultColors.grey);

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: iconPath != null
                                    ? Image.asset(iconPath,
                                        width: 18.w, height: 18.h)
                                    : Icon(Icons.category,
                                        color: color, size: 18.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (d.badge != null) ...[
                                          SizedBox(width: 6.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: (d.badge == 'Nova no mês'
                                                      ? DefaultColors.green
                                                      : DefaultColors.grey)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Text(
                                              d.badge!,
                                              style: TextStyle(
                                                color: d.badge == 'Nova no mês'
                                                    ? DefaultColors.green
                                                    : DefaultColors.grey,
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Mês anterior',
                                                style: TextStyle(
                                                  color: DefaultColors.grey,
                                                  fontSize: 10.sp,
                                                )),
                                            Text(
                                                currencyFormatter
                                                    .format(d.previous),
                                                style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text('Mês atual',
                                                style: TextStyle(
                                                  color: DefaultColors.grey,
                                                  fontSize: 10.sp,
                                                )),
                                            Text(
                                                currencyFormatter
                                                    .format(d.current),
                                                style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Diferença',
                                            style: TextStyle(
                                              color: DefaultColors.grey,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            )),
                                        Row(
                                          children: [
                                            Text(
                                              (d.diff >= 0 ? '+' : '-') +
                                                  currencyFormatter
                                                      .format(d.diff.abs()),
                                              style: TextStyle(
                                                color: diffColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              d.percent == null
                                                  ? (d.badge == 'Nova no mês'
                                                      ? 'Novo'
                                                      : '—')
                                                  : ((d.percent! >= 0
                                                          ? '+'
                                                          : '-') +
                                                      '${d.percent!.abs().toStringAsFixed(1)}%'),
                                              style: TextStyle(
                                                color: diffColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, double> _sumByCategory(
    List<TransactionModel> transactions,
    DateTime start,
    DateTime end,
  ) {
    final Map<int, double> map = {};
    for (final t in transactions) {
      if (t.paymentDay == null) continue;
      if (t.type != TransactionType.despesa) continue;
      if (t.category == null) continue;
      try {
        final date = DateTime.parse(t.paymentDay!);
        if (date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)))) {
          final value = double.parse(t.value
              .replaceAll('R\$', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .trim());
          map[t.category!] = (map[t.category!] ?? 0.0) + value;
        }
      } catch (_) {
        continue;
      }
    }
    return map;
  }
}

class _CategoryDiff {
  final int categoryId;
  final double current;
  final double previous;
  final double diff;
  final double? percent;
  final String? badge;

  _CategoryDiff({
    required this.categoryId,
    required this.current,
    required this.previous,
    required this.diff,
    required this.percent,
    required this.badge,
  });
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 12.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

List<String> getAllMonths() {
  return const [
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
    'Dezembro',
  ];
}
