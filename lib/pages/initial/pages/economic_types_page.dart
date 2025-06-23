import 'package:flutter/material.dart';

class EconomicTipsPage extends StatelessWidget {
  const EconomicTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = {
      '🧠 Hacks Comportamentais': [
        '🛒 Regra dos 7 Dias: Coloque no carrinho e espere 7 dias antes de comprar. Desejo impulsivo passa.',
        '💰 Quantas horas custa?: R\$ 500 = 10h de trabalho (se ganha R\$50/h). Vale a pena?',
        '🔐 Crie barreiras: Deslogue cartões de apps, senha difícil, sem 1 clique.',
      ],
      '🛍️ Compras Inteligentes': [
        '❄️ Compre fora da temporada: Ar-condicionado em agosto, Natal em abril, etc.',
        '👥 Clube de Compras Coletivas: Junte vizinhos para compras no atacado.',
        '🏭 Zona Industrial: Oficinas e serviços 50% mais baratos que no shopping.',
      ],
      '💡 Redução de Custos Escondidos': [
        '🔌 Desligue stand-by: Réguas com botão ON/OFF economizam até R\$200/ano.',
        '📞 Negocie anuais: Desconto de 5–15% ao pagar plano à vista.',
        '📦 Alugue espaço: Vaga, despensa ou armário parado podem virar renda.',
      ],
      '📱 Tecnologia a Seu Favor': [
        '🧾 Extensões de Cashback: Instale MeuDesconto, Zoom no navegador.',
        '💬 Peça desconto direto: Chame no WhatsApp e pergunte sobre desconto no PIX.',
      ],
      '🥦 Alimentação Inteligente': [
        '🥣 Sopa de Geladeira: Use sobras pra fazer sopa toda semana.',
        '🥩 Cortes desvalorizados: Músculo, acém e paleta são 40% mais baratos.',
      ],
      '🚫 Evite Economias Falsas': [
        '👞 Qualidade > Preço: Um sapato de R\$300 que dura 2 anos é melhor que um de R\$100 que dura 3 meses.',
        '📉 Promoção de inúteis: 50% de algo inútil ainda é 100% desperdício.',
      ],
      '💎 Dica Bônus': [
        '💰 Fundo de Emergência: Invista em CDBs com IPCA+ a partir de R\$50/mês. Seguro e melhor que poupança.',
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dicas de Economia'),
        backgroundColor: Colors.green.shade700,
      ),
      body: ListView(
        children: tips.entries.map((entry) {
          return ExpansionTile(
            title: Text(entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            children:
                entry.value.map((tip) => ListTile(title: Text(tip))).toList(),
          );
        }).toList(),
      ),
    );
  }
}
