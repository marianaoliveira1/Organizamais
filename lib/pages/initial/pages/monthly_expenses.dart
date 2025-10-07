import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../controller/auth_controller.dart';
import '../../transaction/pages/category_page.dart';
import '../../../utils/color.dart';
import '../../../widgetes/currency_ipunt_formated.dart';

class MonthlyExpenses extends StatefulWidget {
  const MonthlyExpenses({super.key});

  @override
  State<MonthlyExpenses> createState() => _MonthlyExpensesState();
}

class _MonthlyExpensesState extends State<MonthlyExpenses> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();
    final String? uid = authController.firebaseUser.value?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Orçamento mensal',
          style: TextStyle(color: theme.primaryColor),
        ),
        elevation: 0,
      ),
      body: uid == null
          ? Center(
              child: Text(
                'Faça login para definir seus orçamentos',
                style: TextStyle(color: DefaultColors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('categoryBudgets')
                  .snapshots(),
              builder: (context, snapshot) {
                final Map<int, double> budgets = {};
                if (snapshot.hasData) {
                  for (final d in snapshot.data!.docs) {
                    final data = d.data();
                    final int id =
                        int.tryParse(d.id) ?? data['categoryId'] as int? ?? -1;
                    final double amount =
                        (data['amount'] as num?)?.toDouble() ?? 0.0;
                    if (id >= 0) budgets[id] = amount;
                  }
                }

                // Filtrar e ordenar categorias: primeiro as que têm orçamento definido, depois o restante, ambos A-Z
                final List<Map<String, dynamic>> allCats =
                    List<Map<String, dynamic>>.from(categories_expenses);

                final List<Map<String, dynamic>> filtered = allCats.where((c) {
                  final String name =
                      (c['name'] as String? ?? '').toString().toLowerCase();
                  return _query.isEmpty || name.contains(_query);
                }).toList();

                int nameCompare(
                    Map<String, dynamic> a, Map<String, dynamic> b) {
                  final String an =
                      (a['name'] as String? ?? '').toString().toLowerCase();
                  final String bn =
                      (b['name'] as String? ?? '').toString().toLowerCase();
                  return an.compareTo(bn);
                }

                bool hasBudget(Map<String, dynamic> c) {
                  final int id = (c['id'] as int?) ?? -1;
                  return budgets.containsKey(id);
                }

                final List<Map<String, dynamic>> withBudget =
                    filtered.where(hasBudget).toList()..sort(nameCompare);
                final List<Map<String, dynamic>> withoutBudget = filtered
                    .where((c) => !hasBudget(c))
                    .toList()
                  ..sort(nameCompare);

                final List<Map<String, dynamic>> cats = <Map<String, dynamic>>[
                  ...withBudget,
                  ...withoutBudget
                ];

                return Column(
                  children: [
                    AdsBanner(),
                    SizedBox(
                      height: 10.h,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {
                          _query = value.trim().toLowerCase();
                        }),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, size: 18.sp),
                          hintText: 'Pesquisar categorias',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 12.w),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: cats.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final c = cats[index];
                          final Color color =
                              (c['color'] as Color?) ?? theme.primaryColor;
                          final String icon = (c['icon'] as String?) ?? '';
                          final String name = (c['name'] as String?) ?? '';
                          final int categoryId = (c['id'] as int?) ?? -1;
                          final double? currentBudget = budgets[categoryId];

                          return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 38.w,
                                      height: 38.w,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    if (icon.isNotEmpty)
                                      Image.asset(icon,
                                          width: 24.w, height: 24.w)
                                    else
                                      Icon(Icons.category,
                                          color: Colors.white, size: 18.sp),
                                  ],
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (currentBudget != null)
                                        Text(
                                          'Orçamento: R\$ ${_formatCurrencyBR(currentBudget)}',
                                          style: TextStyle(
                                            color: DefaultColors.grey,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: theme.primaryColor, size: 18.sp),
                                  onPressed: () => _showEditBudgetSheet(context,
                                      uid, categoryId, name, currentBudget),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _showEditBudgetSheet(BuildContext context, String uid, int categoryId,
      String name, double? currentBudget) {
    final theme = Theme.of(context);
    final TextEditingController controller = TextEditingController(
      text: currentBudget != null
          ? 'R\$ ${_formatCurrencyBR(currentBudget)}'
          : '',
    );
    // Preload interstitial before showing the sheet
    AdsInterstitial.preload();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdsBanner(),
              SizedBox(height: 10.h),
              Text(
                'Definir orçamento para $name',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyCentsInputFormatter()],
                decoration: InputDecoration(
                  hintText: 'R\$ 0,00',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        BorderSide(color: theme.primaryColor.withOpacity(.5)),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final String raw = controller.text;
                    final double amount = _parseBR(raw);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('categoryBudgets')
                        .doc(categoryId.toString())
                        .set({'categoryId': categoryId, 'amount': amount},
                            SetOptions(merge: true));
                    // Try show preloaded interstitial; fallback to immediate load
                    try {
                      final shown = await AdsInterstitial.showIfReady();
                      if (!shown) {
                        await AdsInterstitial.show();
                      }
                    } catch (_) {}
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.cardColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Salvar'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  double _parseBR(String raw) {
    final String sanitized = raw
        .replaceAll('R\$', '')
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(sanitized) ?? 0.0;
  }

  String _formatCurrencyBR(double value) {
    final String str = value.toStringAsFixed(2).replaceAll('.', ',');
    final parts = str.split(',');
    String intPart = parts[0];
    final dec = parts.length > 1 ? parts[1] : '00';
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      buf.write(intPart[i]);
      final rem = intPart.length - i - 1;
      if (rem > 0 && rem % 3 == 0) buf.write('.');
    }
    final withDots = buf.toString();
    return '$withDots,$dec';
  }
}
