import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:organizamais/utils/color.dart';
import '../../../ads_banner/ads_banner.dart';
import '../../../controller/transaction_controller.dart';
import '../../../model/transaction_model.dart';

import '../../graphics/widgtes/default_text_graphic.dart';

class CategoryMonthlyChart extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;

  const CategoryMonthlyChart({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController controller = Get.find<TransactionController>();

    return Obx(() {
      final monthlyData = _calculateMonthlyData(controller.transaction);
      final analysis = _generateMonthlyAnalysis(monthlyData);

      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextGraphic(
                  text: "Evolução Mensal da Categoria",
                ),
                SizedBox(height: 8.h),
                Text(
                  'Ano ${DateTime.now().year} (até hoje)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: DefaultColors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    final int monthCount = 12;
                    final double minBarWidth = 8.0;
                    final double minBarSpacing = 8.0;

                    double barWidth =
                        ((availableWidth - (monthCount - 1) * minBarSpacing) /
                                monthCount)
                            .clamp(minBarWidth, 24.0);

                    return SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.center,
                          maxY: _getMaxValue(monthlyData) * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) =>
                                  Colors.blueGrey.withOpacity(0.8),
                              tooltipRoundedRadius: 8,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final month = _getMonthName(group.x.toInt());
                                final value = rod.toY;
                                return BarTooltipItem(
                                  '$month\n${_formatCurrency(value)}',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: SizedBox(
                                      width: barWidth * 3,
                                      child: Text(
                                        _getMonthAbbr(value.toInt()),
                                        style: TextStyle(
                                          color: DefaultColors.grey,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 45,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                interval: _getMaxValue(monthlyData) / 4,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    _formatCurrencyShort(value),
                                    style: TextStyle(
                                      color: DefaultColors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups:
                              _createBarGroups(monthlyData, barWidth: barWidth),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _getMaxValue(monthlyData) / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: DefaultColors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Análise Mensal
          if (analysis.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextGraphic(
                    text: "Análise Mensal",
                  ),
                  SizedBox(height: 16.h),
                  ...analysis.map((item) => _buildAnalysisItem(item, theme)),
                ],
              ),
            ),

          // Dicas Personalizadas
          // Container(
          //   padding: EdgeInsets.all(16.w),
          //   margin: EdgeInsets.only(bottom: 24.h),
          //   decoration: BoxDecoration(
          //     color: theme.cardColor,
          //     borderRadius: BorderRadius.circular(12.r),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       DefaultTextGraphic(
          //         text: "💡 Dicas Inteligentes",
          //       ),
          //       SizedBox(height: 16.h),
          //       ..._getCategoryTips(categoryName, monthlyData, theme),
          //     ],
          //   ),
          // ),
        ],
      );
    });
  }

  Widget _buildAnalysisItem(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: item['cardColor'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: item['cardColor'].withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            item['icon'],
            color: item['cardColor'],
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['month'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['analysis'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: DefaultColors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['message'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: item['cardColor'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMonthlyAnalysis(
      Map<int, double> monthlyData) {
    List<Map<String, dynamic>> analysis = [];
    final currentMonth = DateTime.now().month;

    for (int month = 2; month <= currentMonth; month++) {
      double currentValue = monthlyData[month] ?? 0;
      double previousValue = monthlyData[month - 1] ?? 0;
      double difference = currentValue - previousValue;
      double absoluteDifference = difference.abs();

      if (currentValue > 0 || previousValue > 0) {
        double percentChange = 0;
        if (previousValue > 0) {
          percentChange = (difference / previousValue) * 100;
        } else if (currentValue > 0) {
          percentChange = 100; // Primeira despesa na categoria
        }

        Color cardColor;
        IconData icon;
        String message;

        if (percentChange > 15) {
          cardColor = Colors.red;
          icon = Icons.arrow_upward;
          message = "Alerta: aumento expressivo!";
        } else if (percentChange >= 5 && percentChange <= 15) {
          cardColor = Colors.orange;
          icon = Icons.arrow_upward;
          message = "Aumento moderado";
        } else if (percentChange >= -5 && percentChange <= 5) {
          cardColor = Colors.grey;
          icon = Icons.circle;
          message = "Estável";
        } else if (percentChange >= -15 && percentChange <= -5) {
          cardColor = Colors.green;
          icon = Icons.arrow_downward;
          message = "Boa redução!";
        } else {
          cardColor = Colors.green;
          icon = Icons.arrow_downward;
          message = "Economia significativa!";
        }

        String valueText = difference >= 0
            ? 'Aumentou ${_formatCurrency(absoluteDifference)}'
            : 'Diminuiu ${_formatCurrency(absoluteDifference)}';

        analysis.add({
          'month': _getMonthName(month),
          'analysis': '$valueText (${percentChange.toStringAsFixed(1)}%)',
          'percentChange': percentChange,
          'isPositive': difference > 0,
          'currentValue': currentValue,
          'previousValue': previousValue,
          'cardColor': cardColor,
          'icon': icon,
          'message': message,
        });
      }
    }

    return analysis;
  }

  List<Widget> _getCategoryTips(
      String categoryName, Map<int, double> monthlyData, ThemeData theme) {
    List<String> tips = [];

    // Calcular padrões de gasto
    List<double> values = monthlyData.values.where((v) => v > 0).toList();
    if (values.isEmpty) {
      return [_buildTipItem("Sem dados suficientes para análise", theme)];
    }

    double average = values.reduce((a, b) => a + b) / values.length;
    double maxValue = values.reduce((a, b) => a > b ? a : b);
    int peakMonth =
        monthlyData.entries.firstWhere((e) => e.value == maxValue).key;

    // Dicas específicas por categoria
    switch (categoryName.toLowerCase()) {
      // Grupo Alimentação (Restaurantes, Delivery, Mercado, Lanches)
      case 'alimentação':
      case 'comida':
      case 'restaurante':
      case 'delivery':
      case 'mercado':
      case 'lanches':
      case 'padaria':
      case 'alimentação em viagens':
        tips.addAll([
          'Faça "batch cooking" - cozinhe grandes quantidades e congele porções individuais',
          'Compre cortes de carne menos nobres e aprenda técnicas para deixá-los macios',
          'Crie um "banco de alimentos" com amigos para comprar atacado coletivamente',
          'Use apps como Too Good To Go para comprar excedentes de restaurantes a preços reduzidos',
          'Transforme sobras em novas refeições (ex: arroz vira bolinho, frango vira sanduíche)'
        ]);
        break;

      // Grupo Transporte (Combustível, Uber, Pedágio, etc)
      case 'transporte':
      case 'combustível':
      case 'gasolina':
      case 'uber/99':
      case 'pedágio':
      case 'multas':
      case 'ipva':
      case 'seguro do carro':
        tips.addAll([
          'Experimente a "direção hipereficiente" (manter velocidade constante, antecipar frenagens)',
          'Crie um sistema de caronas rotativas com vizinhos para atividades regulares',
          'Negocie pacotes de corridas com motoristas de aplicativo fixos',
          'Use apps de estacionamento para encontrar vagas gratuitas ou mais baratas',
          'Considere alugar sua vaga de garagem quando não estiver usando'
        ]);
        break;

      // Grupo Moradia (Contas, Manutenção, Casa)
      case 'casa':
      case 'moradia':
      case 'manutenção':
      case 'contas (água, luz, gás, internet)':
      case 'coisas para casa':
        tips.addAll([
          'Instale válvulas de fechamento automático em torneiras para evitar vazamentos',
          'Use garrafas PET cheias de água na caixa acoplada do vaso para reduzir consumo',
          'Crie um "clube de ferramentas" com vizinhos para compartilhar equipamentos',
          'Aplique filme refletivo em janelas para melhorar isolamento térmico',
          'Negocie pacotes de serviços com prestadores fixos (eletricista, encanador)'
        ]);
        break;

      // Grupo Saúde & Bem-estar
      case 'saúde':
      case 'farmácia':
      case 'médico':
      case 'plano de saúde/seguro de vida':
      case 'academia':
      case 'cuidados pessoais':
        tips.addAll([
          'Agende consultas médicas no final do expediente - muitos profissionais oferecem descontos',
          'Participe de programas de prevenção gratuitos oferecidos por planos de saúde',
          'Aprenda automassagem para reduzir idas a massagistas',
          'Compre medicamentos em farmácias de bairro (muitas têm preços melhores que redes)',
          'Use apps de exercícios em casa ao invés de academia quando possível'
        ]);
        break;

      // Grupo Entretenimento & Lazer
      case 'lazer':
      case 'entretenimento':
      case 'cinema/streaming':
      case 'jogos online':
      case 'viagens':
      case 'hospedagens':
      case 'passeios':
      case 'passagens':
        tips.addAll([
          'Assine serviços de streaming durante promoções anuais (Black Friday costuma valer a pena)',
          'Explore programas de fidelidade de companhias aéreas mesmo para voos baratos',
          'Visite atrações turísticas em dias de entrada gratuita ou horários com desconto',
          'Troque experiências (ex: ofereça hospedagem em sua cidade em plataformas de troca)',
          'Compre ingressos de atrações turísticas com antecedência online (muitas vezes mais barato)'
        ]);
        break;

      // Grupo Educação & Desenvolvimento
      case 'educação':
      case 'cursos':
      case 'livros/revistas':
        tips.addAll([
          'Organize grupos de estudo coletivo para dividir custos de cursos caros',
          'Procure edições internacionais de livros técnicos (muitas vezes mais baratas)',
          'Peça samples gratuitos de materiais educacionais diretamente aos fornecedores',
          'Participe como voluntário em eventos acadêmicos para ter acesso gratuito',
          'Venda materiais didáticos antigos para financiar os novos'
        ]);
        break;

      // Grupo Vestuário & Acessórios
      case 'roupas':
      case 'vestuário':
      case 'roupas e acessórios':
        tips.addAll([
          'Organize eventos de troca de roupas com amigos periodicamente',
          'Compre roupas de estação fora de época (agasalhos no verão, roupas de banho no inverno)',
          'Aprenda técnicas básicas de costura para fazer reparos e ajustes',
          'Invista em acessórios versáteis que mudam o visual de poucas peças básicas',
          'Compre roupas de qualidade em leilões de estoque de lojas premium'
        ]);
        break;

      // Grupo Tecnologia & Serviços
      case 'assinaturas e serviços':
      case 'aplicativos':
      case 'streaming':
      case 'taxas':
        tips.addAll([
          'Use cartões pré-pagos para assinaturas e evite cobranças automáticas',
          'Negocie diretamente com atendentes para obter descontos em serviços',
          'Compartilhe contas familiares maximizando os perfis permitidos',
          'Cancele serviços sazonais durante períodos de não uso',
          'Prefira planos anuais quando o desconto for superior a 20%'
        ]);
        break;

      // Grupo Família & Pets
      case 'família e filhos':
      case 'pets':
      case 'pet (veterinário/ração)':
        tips.addAll([
          'Organize uma creche compartilhada com outros pais em seu bairro',
          'Compre ração em sacos grandes e armazene em potes herméticos',
          'Aprenda a fazer brinquedos educativos caseiros para crianças/pets',
          'Negocie pacotes de consultas com veterinários/pediátricas',
          'Junte-se a outros donos de pets para comprar medicamentos em atacado'
        ]);
        break;

      // Grupo Financeiros & Impostos
      case 'impostos':
      case 'financiamento':
      case 'empréstimos':
      case 'doações/caridade':
        tips.addAll([
          'Antecipe pagamentos de impostos quando houver desconto',
          'Considere refinanciar dívidas sempre que as taxas caírem significativamente',
          'Documente doações para abater no imposto de renda',
          'Negocie taxas diretamente com gerentes bancários',
          'Use serviços gratuitos de consultoria financeira oferecidos por algumas instituições'
        ]);
        break;

      default:
        tips.addAll([
          'Implemente a regra 72h: espere 3 dias antes de qualquer gasto não essencial',
          'Crie um sistema de "orçamento reverso" (defina o que quer guardar primeiro)',
          'Automatize transferências para poupança imediatamente após receber o salário',
          'Converse com profissionais da área para descobrir "hacks" específicos',
          'Monitore por 3 meses antes de cortar - alguns gastos trazem retornos ocultos'
        ]);
    }

    // Dicas baseadas em padrões de gasto
    if (peakMonth >= 11 || peakMonth <= 2) {
      tips.add(
          'Gastos maiores no fim/início do ano são normais, mas planeje-se antecipadamente');
    }

    if (values.length > 1) {
      double variation = (values.reduce((a, b) => a > b ? a : b) -
              values.reduce((a, b) => a < b ? a : b)) /
          average;
      if (variation > 0.5) {
        tips.add(
            'Seus gastos variam muito mês a mês. Tente criar uma rotina mais consistente');
      }
    }

    // Selecionar 3-4 dicas mais relevantes
    tips.shuffle();
    return tips.take(4).map((tip) => _buildTipItem(tip, theme)).toList();
  }

  Widget _buildTipItem(String tip, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.blue,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 12.sp,
                color: DefaultColors.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateMonthlyData(List<TransactionModel> transactions) {
    final currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    final monthlyData = <int, double>{};

    // Inicializar todos os meses com zero
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = 0.0;
    }

    // Calcular totais por mês para a categoria específica
    for (final transaction in transactions) {
      if (transaction.paymentDay != null &&
          transaction.category == categoryId &&
          transaction.type == TransactionType.despesa) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        if (paymentDate.year == currentYear &&
            paymentDate.isBefore(currentDate)) {
          final month = paymentDate.month;
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );
          monthlyData[month] = monthlyData[month]! + value;
        }
      }
    }

    return monthlyData;
  }

  List<BarChartGroupData> _createBarGroups(Map<int, double> monthlyData,
      {required double barWidth}) {
    return monthlyData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: categoryColor,
            width: barWidth,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(barWidth * 0.25),
              topRight: Radius.circular(barWidth * 0.25),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxValue(Map<int, double> monthlyData) {
    double maxValue =
        monthlyData.values.fold(0, (max, value) => value > max ? value : max);
    return maxValue == 0 ? 1000 : maxValue;
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months[month - 1];
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
  }
}

class CategoryAnalysisPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;
  final String monthName;
  final double totalValue;
  final double percentual;

  const CategoryAnalysisPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.monthName,
    required this.totalValue,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    List<TransactionModel> transactions =
        _getTransactionsByCategoryAndMonth(categoryId, monthName);

    // Ordena por data (mais recente primeiro)
    transactions.sort((a, b) {
      if (a.paymentDay == null || b.paymentDay == null) return 0;
      return DateTime.parse(b.paymentDay!)
          .compareTo(DateTime.parse(a.paymentDay!));
    });

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          AdsBanner(),
          SizedBox(height: 5.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo da categoria
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          spacing: 5.h,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: DefaultColors.grey20,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(totalValue),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                            Text(
                              '${percentual.toStringAsFixed(1)}% do total',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: DefaultColors.grey20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Card com média mensal
                  _buildMonthlyAverageCard(context, theme),
                  SizedBox(height: 24.h),

                  // Gráfico mensal da categoria
                  CategoryMonthlyChart(
                    categoryId: categoryId,
                    categoryName: categoryName,
                    categoryColor: categoryColor,
                  ),

                  // Lista de transações
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transações em $monthName',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: DefaultColors.grey20,
                          ),
                        ),
                        if (transactions.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Text(
                                "Nenhuma transação encontrada",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: DefaultColors.grey,
                                ),
                              ),
                            ),
                          ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) => Divider(
                            color: DefaultColors.grey20.withOpacity(.5),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            var transaction = transactions[index];
                            var transactionValue = double.parse(
                              transaction.value
                                  .replaceAll('.', '')
                                  .replaceAll(',', '.'),
                            );

                            String formattedDate =
                                transaction.paymentDay != null
                                    ? dateFormatter.format(
                                        DateTime.parse(transaction.paymentDay!),
                                      )
                                    : "Data não informada";

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 180.w,
                                          child: Text(
                                            transaction.title,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Get.theme.primaryColor,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: DefaultColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormatter
                                            .format(transactionValue),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Get.theme.primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        transaction.paymentType ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: DefaultColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyAverageCard(BuildContext context, ThemeData theme) {
    final TransactionController transactionController =
        Get.find<TransactionController>();
    
    // Calcular dados mensais para a categoria
    final monthlyData = _calculateMonthlyDataForCategory(transactionController.transaction);
    
    // Calcular média mensal
    final activeMonths = monthlyData.values.where((value) => value > 0).toList();
    final monthlyAverage = activeMonths.isNotEmpty 
        ? activeMonths.reduce((a, b) => a + b) / activeMonths.length 
        : 0.0;
    
    // Calcular maior e menor gasto
    final maxSpending = activeMonths.isNotEmpty ? activeMonths.reduce((a, b) => a > b ? a : b) : 0.0;
    final minSpending = activeMonths.isNotEmpty ? activeMonths.reduce((a, b) => a < b ? a : b) : 0.0;
    
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: categoryColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Análise da Categoria',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Média Mensal',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(monthlyAverage),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maior Gasto',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(maxSpending),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menor Gasto',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currencyFormatter.format(minSpending),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meses Ativos',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.grey20,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${activeMonths.length} de ${DateTime.now().month}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Get.theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateMonthlyDataForCategory(List<TransactionModel> transactions) {
    final currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    final monthlyData = <int, double>{};

    // Inicializar todos os meses com zero
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = 0.0;
    }

    // Calcular totais por mês para a categoria específica
    for (final transaction in transactions) {
      if (transaction.paymentDay != null &&
          transaction.category == categoryId &&
          transaction.type == TransactionType.despesa) {
        final paymentDate = DateTime.parse(transaction.paymentDay!);
        if (paymentDate.year == currentYear &&
            paymentDate.isBefore(currentDate)) {
          final month = paymentDate.month;
          final value = double.parse(
            transaction.value.replaceAll('.', '').replaceAll(',', '.'),
          );
          monthlyData[month] = monthlyData[month]! + value;
        }
      }
    }

    return monthlyData;
  }

  List<TransactionModel> _getTransactionsByCategoryAndMonth(
      int categoryId, String monthName) {
    final TransactionController transactionController =
        Get.find<TransactionController>();

    List<TransactionModel> getFilteredTransactions() {
      var despesas = transactionController.transaction
          .where((e) => e.type == TransactionType.despesa)
          .toList();

      if (monthName.isNotEmpty) {
        final int currentYear = DateTime.now().year;
        return despesas.where((transaction) {
          if (transaction.paymentDay == null) return false;

          DateTime transactionDate = DateTime.parse(transaction.paymentDay!);
          String transactionMonthName =
              getAllMonths()[transactionDate.month - 1];

          return transactionMonthName == monthName &&
              transactionDate.year == currentYear;
        }).toList();
      }

      return despesas;
    }

    var filteredTransactions = getFilteredTransactions();
    return filteredTransactions
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }

  List<String> getAllMonths() {
    return [
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
  }
}
