import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';

class SelectCategoriesPage extends StatefulWidget {
  const SelectCategoriesPage({
    super.key,
    required this.data,
    required this.initialSelected,
  });

  final List<Map<String, dynamic>> data;
  final Set<int> initialSelected;

  @override
  State<SelectCategoriesPage> createState() => _SelectCategoriesPageState();
}

class _SelectCategoriesPageState extends State<SelectCategoriesPage> {
  late Set<int> _tempSelected;
  late NumberFormat _currencyFormatter;
  bool _showResult = false;

  double get _selectedTotal => widget.data
      .where((e) => _tempSelected.contains(e['category'] as int))
      .fold<double>(0.0, (prev, e) => prev + ((e['value'] as double?) ?? 0.0));

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<int>.from(widget.initialSelected);
    _currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Selecione as categorias'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdsBanner(),
            SizedBox(height: 20.h),
            if (_showResult) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categoria',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      _currencyFormatter.format(_selectedTotal),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Categorias selecionadas',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
            ],
            Expanded(
              child: ListView.separated(
                itemCount: _showResult
                    ? widget.data
                        .where(
                            (e) => _tempSelected.contains(e['category'] as int))
                        .length
                    : widget.data.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: DefaultColors.grey.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final list = _showResult
                      ? widget.data
                          .where((e) =>
                              _tempSelected.contains(e['category'] as int))
                          .toList()
                      : widget.data;
                  final item = list[index];
                  final int catId = item['category'] as int;
                  final String name = (item['name'] ?? 'Categoria') as String;
                  final String? icon = item['icon'] as String?;
                  final Color color =
                      item['color'] as Color? ?? DefaultColors.green;
                  final double value = item['value'] as double? ?? 0.0;

                  final bool isSelected = _tempSelected.contains(catId);

                  return InkWell(
                    onTap: _showResult
                        ? null
                        : () {
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
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: icon == null
                                ? const SizedBox.shrink()
                                : Center(
                                    child: Image.asset(
                                      icon,
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                  ),
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
                          Text(
                            _currencyFormatter.format(value),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                          if (!_showResult) ...[
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
          child: _showResult
              ? Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showResult = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: DefaultColors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Editar seleção',
                            style: TextStyle(
                              color: DefaultColors.green,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: SizedBox(
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
                            'Concluir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showResult = true;
                      });
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
}
