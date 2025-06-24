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
        title: const Text('Dicas de Economia'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.h,
        ),
        child: Column(
          children: [
            AdsBanner(),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    '💡 Pequenos hábitos mudam sua vida financeira!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Confira abaixo algumas dicas práticas e psicológicas para economizar melhor, gastar com mais consciência e usar a tecnologia a seu favor.',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 24),

                  // 🧠 Hacks Comportamentais
                  Text(
                    '🧠 Hacks Comportamentais',
                    style: sectionTitle,
                  ),
                  tip('🛒 Regra dos 7 Dias: coloque no carrinho e espere 7 dias antes de comprar. Impulsos passam.'),
                  tip('💰 Quantas horas custa?: R\$ 500 = 10h de trabalho (se ganha R\$50/h). Vale a pena?'),
                  tip('🔐 Crie barreiras: deslogue cartões, desative 1 clique, use senhas difíceis.'),

                  // 🛍️ Compras Inteligentes
                  Text('🛍️ Compras Inteligentes', style: sectionTitle),
                  tip('❄️ Fora da temporada: ar-condicionado em agosto, Natal em abril, etc.'),
                  tip('👥 Clube Coletivo: junte vizinhos para compras no atacado.'),
                  tip('🏭 Zona Industrial: serviços 50% mais baratos que no shopping.'),

                  // 💡 Redução de Custos Escondidos
                  Text('💡 Redução de Custos Escondidos', style: sectionTitle),
                  tip('🔌 Desligue stand-by: use réguas com botão ON/OFF. Economia de até R\$200/ano.'),
                  tip('📞 Negocie planos anuais: pague à vista e peça desconto (5–15%).'),
                  tip('📦 Alugue espaços ociosos: garagem, armário ou despensa.'),

                  // 📱 Tecnologia a Seu Favor
                  Text('📱 Tecnologia a Seu Favor', style: sectionTitle),
                  tip('🧾 Extensões de Cashback: instale MeuDesconto, Zoom no navegador.'),
                  tip('💬 Peça desconto direto: chame no WhatsApp e pergunte "Tem desconto no PIX?"'),

                  // 🥦 Alimentação Inteligente
                  Text('🥦 Alimentação Inteligente', style: sectionTitle),
                  tip('🥣 Sopa de Geladeira: use sobras para fazer sopa semanal. Zero desperdício.'),
                  tip('🥩 Cortes mais baratos: músculo, acém e paleta. 40% mais baratos e saborosos.'),

                  // 🚫 Evite Economias Falsas
                  Text('🚫 Evite Economias Falsas', style: sectionTitle),
                  tip('👞 Qualidade > preço: um bom sapato que dura 2 anos vale mais que 3 baratos.'),
                  tip('📉 Promoção do que não precisa: ainda é desperdício, mesmo com 50% OFF.'),

                  // 💎 Dica Bônus
                  Text('💎 Dica Bônus', style: sectionTitle),
                  tip('💰 Fundo de Emergência: invista em CDBs com IPCA+. Comece com R\$50/mês. Rende mais que poupança e tem resgate rápido.'),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: DefaultColors.grey,
    height: 2,
  );

  static Widget tip(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Text("• $text", style: TextStyle(fontSize: 15)),
    );
  }
}
