import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:organizamais/controller/auth_controller.dart';
import 'package:organizamais/utils/color.dart';
import 'package:organizamais/pages/transaction/pages/category_page.dart';

class CategoryTypeSelectionPage extends StatefulWidget {
  const CategoryTypeSelectionPage({super.key});

  @override
  State<CategoryTypeSelectionPage> createState() =>
      _CategoryTypeSelectionPageState();
}

class _CategoryTypeSelectionPageState extends State<CategoryTypeSelectionPage> {
  final Map<int, String> _selection =
      {}; // id -> 'fixas' | 'variaveis' | 'extras'
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final user = Get.find<AuthController>().firebaseUser.value;
      if (user == null) {
        // Sem usuário logado, apenas inicia vazio
        setState(() => _loading = false);
        return;
      }
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categoryClassifications')
          .get();
      for (final d in snap.docs) {
        final int id =
            int.tryParse(d.id) ?? (d.data()['categoryId'] as int? ?? -1);
        final String group = (d.data()['group'] as String? ?? '').toLowerCase();
        if (id >= 0 &&
            (group == 'fixas' || group == 'variaveis' || group == 'extras')) {
          _selection[id] = group;
        }
      }
    } catch (_) {
      // conserva silenciosamente
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final user = Get.find<AuthController>().firebaseUser.value;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Faça login para salvar as preferências.')),
      );
      return;
    }
    final batch = FirebaseFirestore.instance.batch();
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categoryClassifications');
    for (final entry in _selection.entries) {
      final doc = col.doc(entry.key.toString());
      batch.set(doc, {
        'categoryId': entry.key,
        'group': entry.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> categories =
        List<Map<String, dynamic>>.from(categories_expenses);

    List<Map<String, dynamic>> filtered = categories.where((c) {
      final name = (c['name'] as String?)?.toLowerCase() ?? '';
      final macro = (c['macrocategoria'] as String?)?.toLowerCase() ?? '';
      final q = _query.toLowerCase();
      return q.isEmpty || name.contains(q) || macro.contains(q);
    }).toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classificar categorias'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.save_2),
            onPressed: _loading ? null : _save,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar categoria…',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: theme.dividerColor.withOpacity(.2)),
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      final int id = c['id'] as int;
                      final String name = c['name'] as String;
                      final String group = _selection[id] ?? 'variaveis';
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 4.h),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 100.w,
                          child: DropdownButtonFormField<String>(
                            value: group,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            items: const [
                              DropdownMenuItem(
                                  value: 'fixas', child: Text('Fixas')),
                              DropdownMenuItem(
                                  value: 'variaveis', child: Text('Variáveis')),
                              DropdownMenuItem(
                                  value: 'extras', child: Text('Extras')),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selection[id] = v);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h, // altura fixa parecida com o print
                      child: ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor, // fundo preto
                          // foregroundColor: theme.primaryColor, // texto branco
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30.r), // pill shape
                          ),
                          elevation: 0, // sem sombra (flat)
                        ),
                        child: Text(
                          'Salvar',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: theme.scaffoldBackgroundColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
