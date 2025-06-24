import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';

class EconomicTipsPage extends StatelessWidget {
  const EconomicTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Dicas de Economia Inteligente'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          AdsBanner(),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TipCard(
                  title: 'Dica Nada Óbvia: O Clube da Troca de Habilidades',
                  description:
                      'Em vez de pagar por serviços (como cortar o cabelo, consertar algo, dar aulas de algo que você domina), troque habilidades com amigos ou vizinhos. Você faz algo para eles e eles fazem algo para você. É economia direta e ainda fortalece laços!',
                  isObvious: false,
                  // Usando a cor principal do tema para títulos não óbvios
                  textColor: Theme.of(context).primaryColor,
                ),
                TipCard(
                  title:
                      'Dica Nada Óbvia: Reavalie Suas "Necessidades Sociais"',
                  description:
                      'Muitos gastos vêm da pressão social: sair todo fim de semana, comprar a roupa da moda, ter o gadget mais recente. Questione se essas atividades realmente te trazem felicidade ou se são apenas para "acompanhar". Priorize experiências que não custam fortunas.',
                  isObvious: false,
                  textColor: Theme.of(context).primaryColor,
                ),
                TipCard(
                  title: 'Dica Nada Óbvia: A Regra do "Custo Por Uso"',
                  description:
                      'Antes de comprar algo, principalmente algo caro, calcule quantas vezes você realmente vai usar. Uma máquina de café superpotente que você usa uma vez por mês tem um "custo por uso" altíssimo. Alugar ou pegar emprestado pode ser mais inteligente.',
                  isObvious: false,
                  textColor: Theme.of(context).primaryColor,
                ),
                TipCard(
                  title:
                      'Dica Nada Óbvia: Venda o Que Não Usa (e Não Sentirá Falta)',
                  description:
                      'Você provavelmente tem itens em casa que não usa há anos. Roupas, livros, eletrônicos. Desapegue! Venda-os em plataformas online. Além de liberar espaço, o dinheiro extra pode ser um ótimo impulso para sua poupança.',
                  isObvious: false,
                  textColor: Theme.of(context).primaryColor,
                ),
                TipCard(
                  title: 'Dica Nada Óbvia: Auditoria de Assinaturas (a Fundo!)',
                  description:
                      'Não olhe só os serviços de streaming. Inclua apps de celular, academias que você não frequenta, jornais digitais que não lê. Muitas vezes nos esquecemos de pequenas assinaturas que se somam a um valor considerável. Use apps de gerenciamento financeiro para rastreá-las.',
                  isObvious: false,
                  textColor: Theme.of(context).primaryColor,
                ),
                TipCard(
                  title: 'Dica Nada Óbvia: O Desafio do "Dia Sem Gastos"',
                  description:
                      'Escolha um dia na semana (ou até alguns dias no mês) onde você se compromete a não gastar absolutamente nada, a não ser o essencial. Leve marmita, não compre café, evite sair. É um exercício de disciplina que mostra o quanto você gasta "sem pensar".',
                  isObvious: false,
                  textColor: Theme.of(context).primaryColor,
                ),
                TipCard(
                  title: 'Dica Óbvia: Crie um Orçamento e Siga-o',
                  description:
                      'Anote todas as suas receitas e despesas. Saber para onde seu dinheiro está indo é o primeiro passo para ter controle e economizar. Defina limites para cada categoria de gasto.',
                  isObvious: true,
                  textColor: DefaultColors.grey20,
                ),
                TipCard(
                  title: 'Dica Óbvia: Cozinhe Mais em Casa e Leve Marmita',
                  description:
                      'Comer fora é um dos maiores vilões do orçamento. Preparar suas próprias refeições é geralmente mais barato e saudável. Leve sua marmita para o trabalho ou faculdade.',
                  isObvious: true,
                  textColor: DefaultColors.grey20,
                ),
                TipCard(
                  title: 'Dica Óbvia: Evite Compras por Impulso',
                  description:
                      'Antes de comprar algo, especialmente itens não essenciais, dê um tempo. Espere 24 horas, ou até alguns dias, para ver se você realmente precisa ou deseja o item. Muitas vezes, o impulso passa.',
                  isObvious: true,
                  textColor: DefaultColors.grey20,
                ),
                TipCard(
                  title: 'Dica Óbvia: Pesquise Preços Antes de Comprar',
                  description:
                      'Não compre no primeiro lugar. Compare preços em diferentes lojas físicas e online. Usar comparadores de preço pode te poupar um bom dinheiro.',
                  isObvious: true,
                  textColor: DefaultColors.grey20,
                ),
                TipCard(
                  title:
                      'Dica Óbvia: Use o Transporte Público ou Vá a Pé/Bicicleta',
                  description:
                      'Reduza o uso do carro. Além do combustível, há gastos com manutenção, estacionamento e impostos. O transporte público, bicicleta ou caminhadas são alternativas mais econômicas e, muitas vezes, mais saudáveis.',
                  isObvious: true,
                  textColor: DefaultColors.grey20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isObvious;
  final Color textColor; // Adicionamos uma propriedade para a cor do texto

  const TipCard({
    super.key,
    required this.title,
    required this.description,
    required this.isObvious,
    required this.textColor, // Agora é obrigatório passar a cor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.r,
        ), // Bordas arredondadas
      ),
      child: Padding(
        padding: EdgeInsets.all(14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: textColor, // Usando a cor passada via construtor
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 13.sp,
                color: DefaultColors.grey20,
              ), // Cor do texto da descrição
            ),
          ],
        ),
      ),
    );
  }
}
