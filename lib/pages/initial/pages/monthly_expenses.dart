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

                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdsBanner(),
                      SizedBox(height: 14.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _buildSearchField(theme),
                      ),
                      SizedBox(height: 12.h),
                      Expanded(
                        child: cats.isEmpty
                            ? _buildEmptyState(theme)
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 28.h),
                                itemCount: cats.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 12.h),
                                itemBuilder: (context, index) {
                                  final c = cats[index];
                                  final Color color = (c['color'] as Color?) ??
                                      theme.primaryColor;
                                  final String icon =
                                      (c['icon'] as String?) ?? '';
                                  final String name =
                                      (c['name'] as String?) ?? '';
                                  final int categoryId =
                                      (c['id'] as int?) ?? -1;
                                  final double? currentBudget =
                                      budgets[categoryId];

                                  return _buildCategoryTile(
                                    theme: theme,
                                    name: name,
                                    iconPath: icon,
                                    color: color,
                                    currentBudget: currentBudget,
                                    onTap: () => _showEditBudgetSheet(
                                      context,
                                      uid,
                                      categoryId,
                                      name,
                                      currentBudget,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeaderCard(
      ThemeData theme, int categoriesWithBudget, int totalCategories) {
    final bool hasBudgets = categoriesWithBudget > 0;
    final String title =
        hasBudgets ? 'Revise seus limites' : 'Comece pelos limites';
    final String subtitle = hasBudgets
        ? '$categoriesWithBudget de $totalCategories categorias já possuem orçamento configurado.'
        : 'Defina um valor mensal para cada categoria e acompanhe o quanto ainda pode gastar.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.pie_chart_outline_rounded,
              color: theme.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() {
        _query = value.trim().toLowerCase();
      }),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, size: 18.sp, color: theme.primaryColor),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close,
                    size: 16.sp, color: theme.primaryColor.withOpacity(0.7)),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              )
            : null,
        hintText: 'Pesquisar categorias',
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.4)),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      ),
      style: TextStyle(
        fontSize: 13.sp,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.playlist_add_outlined,
                color: theme.primaryColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Nenhuma categoria encontrada',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ajuste o termo de busca ou crie um orçamento para começar a acompanhar seus limites.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.primaryColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required ThemeData theme,
    required String name,
    required String iconPath,
    required Color color,
    required double? currentBudget,
    required VoidCallback onTap,
  }) {
    final bool hasBudget = currentBudget != null && currentBudget > 0;
    final String subtitle = hasBudget
        ? 'Limite mensal configurado'
        : 'Toque para definir um orçamento';
    final double budgetValue = currentBudget ?? 0;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  if (iconPath.isNotEmpty)
                    Image.asset(iconPath, width: 26.w, height: 26.w)
                  else
                    Icon(Icons.category_outlined,
                        color: theme.cardColor, size: 20.sp),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: DefaultColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: hasBudget
                      ? theme.primaryColor.withOpacity(0.12)
                      : theme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color:
                        theme.primaryColor.withOpacity(hasBudget ? 0.2 : 0.12),
                  ),
                ),
                child: Text(
                  hasBudget
                      ? 'R\$ ${_formatCurrencyBR(budgetValue)}'
                      : 'Definir',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.primaryColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
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
    final String buttonLabel =
        currentBudget != null ? 'Atualizar orçamento' : 'Salvar orçamento';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 16.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  currentBudget != null
                      ? 'Atualize o orçamento'
                      : 'Defina um orçamento',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Esse limite será usado nos alertas e comparativos mensais.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.primaryColor.withOpacity(0.75),
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18.r),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categoria',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: theme.primaryColor.withOpacity(0.6),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Valor mensal',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyCentsInputFormatter()],
                  decoration: InputDecoration(
                    hintText: 'R\$ 0,00',
                    filled: true,
                    fillColor: theme.cardColor,
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: theme.primaryColor,
                      size: 18.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: BorderSide(
                        color: theme.primaryColor.withOpacity(0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: BorderSide(
                        color: theme.primaryColor.withOpacity(0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: BorderSide(
                        color: theme.primaryColor.withOpacity(0.4),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 12.w,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(
                            color: theme.primaryColor.withOpacity(0.3),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final String raw = controller.text;
                          final double amount = _parseBR(raw);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('categoryBudgets')
                              .doc(categoryId.toString())
                              .set(
                            {'categoryId': categoryId, 'amount': amount},
                            SetOptions(merge: true),
                          );
                          await AdsInterstitial.show();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.cardColor,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(buttonLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
