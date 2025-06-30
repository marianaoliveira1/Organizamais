// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../model/transaction_model.dart';

final List<Map<String, dynamic>> categories_expenses = [
  // ========== MORADIA E CASA ==========
  {
    'id': 5,
    'name': 'Moradia',
    'icon': 'assets/icon-category/home.png',
    'color': DefaultColors.blue,
    'synonyms': ['casa', 'aluguel', 'hipoteca', 'condomínio'],
    'relations': ['habitação', 'imóvel', 'residência']
  },
  {
    'id': 26,
    'name': 'Contas (água, luz, gás, internet)',
    'icon': 'assets/icon-category/contas.png',
    'color': DefaultColors.skyBlue,
    'synonyms': ['utilidades', 'energia', 'wifi', 'conta de luz']
  },
  {
    'id': 65,
    'name': 'Coisas para Casa',
    'icon': 'assets/icon-category/coisasparacasa.png',
    'color': DefaultColors.pastelBlue,
    'synonyms': ['móveis', 'decoração', 'eletrodomésticos', 'utensílios']
  },
  {
    'id': 19,
    'name': 'Manutenção e reparos',
    'icon': 'assets/icon-category/manutencao.png',
    'color': DefaultColors.titanium,
    'synonyms': ['reforma', 'conserto', 'reparo', 'serviços domésticos']
  },

  // ========== ALIMENTAÇÃO ==========
  {
    'id': 1,
    'name': 'Alimentação',
    'icon': 'assets/icon-category/food.png',
    'color': DefaultColors.emeraldBright,
    'synonyms': ['comida', 'supermercado', 'feira', 'despensa']
  },
  {
    'id': 29,
    'name': 'Mercado',
    'icon': 'assets/icon-category/mercado.png',
    'color': DefaultColors.vibrantGreen,
    'synonyms': ['compra do mês', 'hortifruti', 'despensa']
  },
  {
    'id': 4,
    'name': 'Restaurantes',
    'icon': 'assets/icon-category/restaurante.png',
    'color': DefaultColors.scarlet,
    'synonyms': ['jantar fora', 'delivery', 'fast food']
  },
  {
    'id': 21,
    'name': 'Delivery',
    'icon': 'assets/icon-category/delivery-bike.png',
    'color': DefaultColors.orangeDark,
    'synonyms': ['Ifood', 'Uber Eats', 'comida pronta']
  },
  {
    'id': 31,
    'name': 'Lanches',
    'icon': 'assets/icon-category/lanches.png',
    'color': DefaultColors.vibrantYellow,
    'synonyms': ['petisco', 'fast food', 'salgadinho']
  },
  {
    'id': 69,
    'name': 'Padaria',
    'icon': 'assets/icon-category/padaria.png',
    'color': DefaultColors.sandyBeige,
    'synonyms': ['pão', 'confeitaria', 'doces']
  },

  // ========== TRANSPORTE ==========
  {
    'id': 17,
    'name': 'Transporte',
    'icon': 'assets/icon-category/car.png',
    'color': DefaultColors.indigo,
    'synonyms': ['ônibus', 'metrô', 'combustível', 'táxi']
  },
  {
    'id': 28,
    'name': 'Combustível',
    'icon': 'assets/icon-category/combustivel.png',
    'color': DefaultColors.amber,
    'synonyms': ['gasolina', 'posto', 'abastecimento']
  },
  {
    'id': 22,
    'name': 'Transporte por Aplicativo',
    'icon': 'assets/icon-category/taxi.png',
    'color': DefaultColors.deepPurple,
    'synonyms': ['aplicativo de transporte', 'carona']
  },
  {
    'id': 71,
    'name': 'Pedágio',
    'icon': 'assets/icon-category/pedagios.png',
    'color': DefaultColors.slateGrey,
    'synonyms': ['tarifa rodoviária', 'estrada']
  },
  {
    'id': 33,
    'name': 'Multas',
    'icon': 'assets/icon-category/multas.png',
    'color': DefaultColors.redDark,
    'synonyms': ['infração', 'trânsito', 'penalidade']
  },
  {
    'id': 70,
    'name': 'IPVA',
    'icon': 'assets/icon-category/ipva.png',
    'color': DefaultColors.cobalt,
    'synonyms': ['licenciamento', 'taxa veicular']
  },
  {
    'id': 32,
    'name': 'Seguro do Carro',
    'icon': 'assets/icon-category/seguros.png',
    'color': DefaultColors.blueGrey,
    'synonyms': ['seguro auto', 'proteção veicular']
  },

  // ========== SAÚDE E BEM-ESTAR ==========
  {
    'id': 15,
    'name': 'Saúde',
    'icon': 'assets/icon-category/saude.png',
    'color': DefaultColors.vibrantTeal,
    'synonyms': ['médico', 'hospital', 'plano de saúde']
  },
  {
    'id': 86, // NOVA
    'name': 'Exames',
    'icon': 'assets/icon-category/exames.png',
    'color': DefaultColors.lightBlue,
    'synonyms': ['produtos de limpeza', 'faxina', 'empregada doméstica']
  },
  {
    'id': 24,
    'name': 'Farmácia',
    'icon': 'assets/icon-category/farmacia.png',
    'color': DefaultColors.pastelRed,
    'synonyms': ['remédio', 'medicamento', 'drogaria']
  },
  {
    'id': 36,
    'name': 'Plano de Saúde/Seguro de vida',
    'icon': 'assets/icon-category/planodesaude.png',
    'color': DefaultColors.teal,
    'synonyms': ['convênio médico', 'assistência médica']
  },
  {
    'id': 87, // NOVA
    'name': 'Consultas Médicas',
    'icon': 'assets/icon-category/consultas.png',
    'color': DefaultColors.indigoLight,
    'synonyms': ['médico', 'dentista', 'psicólogo', 'terapia']
  },
  {
    'id': 88, // NOVA
    'name': 'Salão/Barbearia',
    'icon': 'assets/icon-category/salao.png',
    'color': DefaultColors.pink,
    'synonyms': ['cabeleireiro', 'corte de cabelo', 'beleza', 'estética']
  },
  {
    'id': 7,
    'name': 'Cuidados pessoais',
    'icon': 'assets/icon-category/skincare.png',
    'color': DefaultColors.pastelPurple,
    'synonyms': ['cosméticos', 'higiene', 'perfumaria']
  },
  {
    'id': 25,
    'name': 'Academia',
    'icon': 'assets/icon-category/academia.png',
    'color': DefaultColors.lightGreen,
    'synonyms': ['ginástica', 'treino', 'fitness']
  },

  // ========== EDUCAÇÃO ==========
  {
    'id': 9,
    'name': 'Educação',
    'icon': 'assets/icon-category/education.png',
    'color': DefaultColors.deepPurpleDark,
    'synonyms': ['escola', 'curso', 'faculdade', 'material escolar']
  },
  {
    'id': 76,
    'name': 'Livros/Revistas',
    'icon': 'assets/icon-category/livros.png',
    'color': DefaultColors.earthBrown,
    'synonyms': ['leitura', 'biblioteca', 'ebook']
  },

  // ========== LAZER E ENTRETENIMENTO ==========
  {
    'id': 12,
    'name': 'Lazer e hobbies',
    'icon': 'assets/icon-category/lazer.png',
    'color': DefaultColors.tangerine,
    'synonyms': ['cinema', 'parque', 'passeio', 'hobby']
  },
  {
    'id': 3,
    'name': 'Bares',
    'icon': 'assets/icon-category/wine.png',
    'color': DefaultColors.burgundy,
    'synonyms': ['happy hour', 'drinks', 'boteco']
  },
  {
    'id': 75,
    'name': 'Cinema',
    'icon': 'assets/icon-category/cinema.png',
    'color': DefaultColors.amethyst,
    'synonyms': ['Netflix', 'ingresso', 'filme']
  },
  {
    'id': 23,
    'name': 'Streaming',
    'icon': 'assets/icon-category/streaming.png',
    'color': DefaultColors.electricPurple,
    'synonyms': ['Spotify', 'Disney+', 'assinatura']
  },
  {
    'id': 68,
    'name': 'Jogos Online',
    'icon': 'assets/icon-category/jogosonline.png',
    'color': DefaultColors.neonGreen,
    'synonyms': ['videogame', 'steam', 'game pass']
  },
  {
    'id': 74,
    'name': 'Viagens',
    'icon': 'assets/icon-category/viagens.png',
    'color': DefaultColors.oceanBlue,
    'synonyms': ['férias', 'turismo', 'passeio']
  },
  {
    'id': 62,
    'name': 'Hospedagens',
    'icon': 'assets/icon-category/hoteis.png',
    'color': DefaultColors.gold,
    'synonyms': ['hotel', 'Airbnb', 'resort']
  },
  {
    'id': 61,
    'name': 'Passagens',
    'icon': 'assets/icon-category/passagens.png',
    'color': DefaultColors.lightBlue,
    'synonyms': ['avião', 'ônibus', 'viagem']
  },
  {
    'id': 63,
    'name': 'Alimentação em Viagens',
    'icon': 'assets/icon-category/alimentacaoemviagens.png',
    'color': DefaultColors.coral,
    'synonyms': ['comida de viagem', 'restaurante turístico']
  },
  {
    'id': 64,
    'name': 'Passeios',
    'icon': 'assets/icon-category/passeios.png',
    'color': DefaultColors.sunflowerYellow,
    'synonyms': ['turismo', 'ponto turístico', 'excursão']
  },

  // ========== COMPRAS ==========
  {
    'id': 6,
    'name': 'Compras',
    'icon': 'assets/icon-category/shopping.png',
    'color': DefaultColors.hotPink,
    'synonyms': ['shopping', 'loja', 'e-commerce']
  },
  {
    'id': 20,
    'name': 'Vestuário',
    'icon': 'assets/icon-category/roupas.png',
    'color': DefaultColors.plum,
    'synonyms': ['roupa', 'moda', 'vestido']
  },
  {
    'id': 34,
    'name': 'Roupas e acessórios',
    'icon': 'assets/icon-category/roupas-e-calcados.png',
    'color': DefaultColors.lavender,
    'synonyms': ['calçados', 'bolsas', 'joias']
  },
  {
    'id': 14,
    'name': 'Presentes',
    'icon': 'assets/icon-category/gift.png',
    'color': DefaultColors.vibrantPink,
    'synonyms': ['lembrança', 'mimo', 'aniversário']
  },

  // ========== PETS ==========
  {
    'id': 13,
    'name': 'Pets',
    'icon': 'assets/icon-category/dog.png',
    'color': DefaultColors.emerald,
    'synonyms': ['animal', 'veterinário', 'pet shop']
  },
  // {
  //   'id': 78,
  //   'name': 'Pet (Veterinário/Ração)',
  //   'icon': 'assets/icon-category/pet.png',
  //   'color': DefaultColors.jungleGreen,
  //   'synonyms': ['gato', 'cachorro', 'animal de estimação']
  // },

  // ========== FINANÇAS ==========
  {
    'id': 35,
    'name': 'Impostos',
    'icon': 'assets/icon-category/impostos.png',
    'color': DefaultColors.grey,
    'synonyms': ['IPTU', 'IRPF', 'tributo']
  },
  {
    'id': 37,
    'name': 'Financiamento',
    'icon': 'assets/icon-category/financiamentos.png',
    'color': DefaultColors.sapphire,
    'synonyms': ['empréstimo', 'parcela', 'crédito']
  },
  {
    'id': 38,
    'name': 'Empréstimos',
    'icon': 'assets/icon-category/emprestimos.png',
    'color': DefaultColors.greenDark,
    'synonyms': ['dívida', 'crediário', 'consignado']
  },
  {
    'id': 79,
    'name': 'Taxas',
    'icon': 'assets/icon-category/taxas.png',
    'color': DefaultColors.magenta,
    'synonyms': ['tarifa', 'anuidade', 'juros']
  },
  {
    'id': 2,
    'name': 'Assinaturas e serviços',
    'icon': 'assets/icon-category/cartao.png',
    'color': DefaultColors.navy,
    'synonyms': ['mensalidade', 'plano', 'serviço']
  },
  {
    'id': 67,
    'name': 'Aplicativos',
    'icon': 'assets/icon-category/app.png',
    'color': DefaultColors.ultramarineBlue,
    'synonyms': ['software', 'app pago', 'assinatura']
  },
  {
    'id': 80,
    'name': 'Seguros',
    'icon': 'assets/icon-category/seguros.png',
    'color': DefaultColors.topaz,
    'synonyms': ['proteção', 'apólice', 'seguro residencial']
  },

  // ========== FAMÍLIA ==========
  {
    'id': 10,
    'name': 'Família e filhos',
    'icon': 'assets/icon-category/family.png',
    'color': DefaultColors.pastelGreen,
    'synonyms': ['criança', 'escola', 'creche']
  },
  {
    'id': 77,
    'name': 'Doações/Caridade',
    'icon': 'assets/icon-category/doacoes.png',
    'color': DefaultColors.rosyPink,
    'synonyms': ['ONG', 'solidariedade', 'contribuição']
  },

  // ========== TRABALHO ==========
  {
    'id': 16,
    'name': 'Trabalho',
    'icon': 'assets/icon-category/work.png',
    'color': DefaultColors.indigoDark,
    'synonyms': ['escritório', 'material', 'profissional']
  },

  // ========== IMPREVISTOS ==========
  {
    'id': 66,
    'name': 'Emergência',
    'icon': 'assets/icon-category/emergency.png',
    'color': DefaultColors.brightRed,
    'synonyms': ['imprevisto', 'urgência', 'socorro']
  },

  // ========== OUTROS ==========
  {
    'id': 30,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.darkGrey,
    'synonyms': ['diversos', 'variados', 'geral']
  },
];

// [Continua com as categorias de renda...]

final List<Map<String, dynamic>> categories_income = [
  {
    'id': 50,
    'name': 'Salário',
    'icon': 'assets/icon-category/mooney.png',
    'color': Colors.green,
    'synonyms': [
      'pagamento',
      'remuneração',
      'ordenado',
      'vencimento',
      'proventos',
      'contracheque'
    ],
    'relations': [
      'pagamento',
      'remuneração',
      'ordenado',
      'vencimento',
      'proventos',
      'contracheque',
      'trabalho',
      'emprego',
      'renda'
    ],
  },
  {
    'id': 51,
    'name': 'Poupança',
    'icon': 'assets/icon-category/renda.png',
    'color': Colors.blue,
    'synonyms': [
      'economia',
      'investimento',
      'reserva',
      'guardado',
      'aplicação'
    ],
    'relations': [
      'economia',
      'investimento',
      'reserva',
      'guardado',
      'aplicação',
      'finanças',
      'banco',
      'rendimento'
    ],
  },
  {
    'id': 52,
    'name': 'Bonificação',
    'icon': 'assets/icon-category/bonus.png',
    'color': Colors.blue,
    'synonyms': ['bônus', 'prêmio', 'gratificação', 'comissão', 'incentivo'],
    'relations': [
      'bônus',
      'prêmio',
      'gratificação',
      'comissão',
      'incentivo',
      'trabalho',
      'salário',
      'renda extra'
    ],
  },
  {
    'id': 53,
    'name': 'Renda extra',
    'icon': 'assets/icon-category/income.png',
    'color': Colors.blue,
    'synonyms': ['extra', 'adicional', 'complemento', 'bico', 'ganho extra'],
    'relations': [
      'extra',
      'adicional',
      'complemento',
      'bico',
      'ganho extra',
      'renda extra'
    ],
  },
  {
    'id': 54,
    'name': 'Transfrencia bancária',
    'icon': 'assets/icon-category/transfer.png',
    'color': Colors.blue,
    'synonyms': ['transferência', 'pix', 'ted', 'doc', 'depósito'],
    'relations': [
      'transferência',
      'pix',
      'ted',
      'doc',
      'depósito',
      'banco',
      'finanças'
    ],
  },
  {
    'id': 58,
    'name': 'Freelance',
    'icon': 'assets/icon-category/freelancer.png',
    'color': DefaultColors.teal,
    'synonyms': [
      'autônomo',
      'freelancer',
      'trabalho independente',
      'projeto',
      'serviço avulso'
    ],
    'relations': [
      'autônomo',
      'freelancer',
      'trabalho independente',
      'projeto',
      'serviço avulso'
    ],
  },
  {
    'id': 59,
    'name': 'Indenização',
    'icon': 'assets/icon-category/indenização.png',
    'color': DefaultColors.lavender,
    'synonyms': [
      'ressarcimento',
      'reembolso',
      'compensação',
      'restituição',
      'reparo'
    ],
    'relations': [
      'ressarcimento',
      'reembolso',
      'compensação',
      'restituição',
      'reparo'
    ],
  },
  {
    'id': 60,
    'name': 'Prêmios',
    'icon': 'assets/icon-category/premios.png',
    'color': DefaultColors.peach,
    'synonyms': [
      'premiação',
      'recompensa',
      'conquista',
      'troféu',
      'reconhecimento'
    ],
    'relations': [
      'premiação',
      'recompensa',
      'conquista',
      'troféu',
      'reconhecimento'
    ],
  },
  {
    'id': 81,
    'name': 'Aluguel Recebido',
    'icon': 'assets/icon-category/aluguel.png',
    'color': DefaultColors.chartreuse, // Nova cor
    'synonyms': ['imóvel', 'renda imobiliária'],
    'relations': ['investimento', 'moradia'],
  },
  {
    'id': 82,
    'name': 'Dividendos',
    'icon': 'assets/icon-category/dividendos.png',
    'color': DefaultColors.forestGreen, // Nova cor
    'synonyms': ['investimentos', 'ações'],
    'relations': ['renda passiva', 'finanças'],
  },
  {
    'id': 83,
    'name': 'Venda de Itens Usados',
    'icon': 'assets/icon-category/vendas.png',
    'color': DefaultColors.tangerine, // Nova cor
    'synonyms': ['brechó', 'usado'],
    'relations': ['compras', 'renda extra'],
  },
  {
    'id': 84,
    'name': 'Reembolsos',
    'icon': 'assets/icon-category/reembolso.png',
    'color': DefaultColors.seaGreen, // Nova cor
    'synonyms': ['devolução', 'estorno'],
    'relations': ['compras', 'finanças'],
  },
  {
    'id': 85,
    'name': 'Pensão Alimentícia',
    'icon': 'assets/icon-category/pensao.png',
    'color': DefaultColors.oliveGreen, // Nova cor
    'synonyms': ['alimentos', 'judicial'],
    'relations': ['família', 'filhos'],
  },
  {
    'id': 55,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.grey,
    'synonyms': [
      'diversos',
      'variados',
      'miscelânea',
      'outro',
      'demais',
      'geral'
    ],
    'relations': [
      'diversos',
      'variados',
      'miscelânea',
      'outro',
      'demais',
      'geral',
      'receitas',
      'renda'
    ],
  },
];

final List<Map<String, dynamic>> all_categories = [
  ...categories_expenses,
  ...categories_income
];

Map<String, dynamic>? findCategoryById(int? id) {
  if (id == null) return null;

  final expenseCategory = categories_expenses.firstWhere(
    (category) => category['id'] == id,
    orElse: () => {'id': 0, 'name': '', 'icon': ''},
  );
  if (expenseCategory['id'] != 0) return expenseCategory;

  final incomeCategory = categories_income.firstWhere(
    (category) => category['id'] == id,
    orElse: () => {'id': 0, 'name': '', 'icon': ''},
  );
  if (incomeCategory['id'] != 0) return incomeCategory;

  return null;
}

class CategoryPage extends StatefulWidget {
  final TransactionType? transactionType;

  const CategoryPage({
    super.key,
    this.transactionType,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final searchController = TextEditingController();
  late List<Map<String, dynamic>> allCategories;
  late List<Map<String, dynamic>> filteredCategories;

  @override
  void initState() {
    super.initState();
    allCategories = List<Map<String, dynamic>>.from(
        widget.transactionType == TransactionType.receita
            ? categories_income
            : categories_expenses);
    filteredCategories = List<Map<String, dynamic>>.from(allCategories);
    searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterCategories);
    searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = searchController.text.trim();

    setState(() {
      if (query.isEmpty) {
        // Reset to all categories if query is empty
        filteredCategories = List<Map<String, dynamic>>.from(allCategories);
      } else {
        // Filter categories based on name and synonyms
        filteredCategories = allCategories.where((category) {
          final name = category.toString().toLowerCase();
          final searchQuery = query.toLowerCase();

          // Check if name contains query
          if (name.contains(searchQuery)) {
            return true;
          }

          // Check if any synonym contains query
          final synonyms = category['synonyms'] as List<String>?;
          if (synonyms != null && synonyms.isNotEmpty) {
            return synonyms
                .map((s) => s.toLowerCase())
                .any((s) => s.contains(searchQuery));
          }

          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Categorias',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: searchController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
              decoration: InputDecoration(
                hintText: 'Pesquisar categoria',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor.withOpacity(0.5),
                ),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12.r,
                  ),
                ),
                prefixIconColor: DefaultColors.grey,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12.r,
                  ),
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                  ),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
            ),
          ),
          AdsBanner(),
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma categoria encontrada',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.hintColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 20.w,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 10.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 6.w,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(
                            14.r,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: DefaultColors.grey.withOpacity(
                              .1,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                8.h,
                              ),
                              child: Image.asset(
                                category['icon'],
                                height: 26.h,
                              ),
                            ),
                          ),
                          title: Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          onTap: () {
                            Get.back(
                              result: category['id'],
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
