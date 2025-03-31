// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../../../model/transaction_model.dart';

final List<Map<String, dynamic>> categories_expenses = [
  {
    'id': 5,
    'name': 'Moradia',
    'icon': 'assets/icon-category/home.png',
    'color': DefaultColors.blue,
    'synonyms': [
      'casa',
      'lar',
      'apartamento',
      'residência',
      'imóvel',
      'aluguel',
      'habitação',
      'moradia'
    ],
    'relations': [
      'casa',
      'lar',
      'apartamento',
      'residência',
      'imóvel',
      'aluguel',
      'habitação',
      'moradia'
    ],
  },
  {
    'id': 19,
    'name': 'Manutenção e reparos',
    'icon': 'assets/icon-category/manutencao.png',
    'color': DefaultColors.titanium,
    'synonyms': [
      'conserto',
      'reparo',
      'reforma',
      'concerto',
      'manutenção',
      'consertos',
      'reparos',
      'reformas'
    ],
    'relations': [
      'conserto',
      'reparo',
      'reforma',
      'concerto',
      'manutenção',
      'consertos',
      'reparos',
      'reformas',
      'casa',
      'carro',
      'equipamento'
    ],
  },
  {
    'id': 26,
    'name': 'Contas (água, luz, gás, internet)',
    'icon': 'assets/icon-category/contas.png',
    'color': DefaultColors.skyBlue,
    'synonyms': [
      'água',
      'luz',
      'energia',
      'gás',
      'internet',
      'wifi',
      'contas fixas',
      'utilidades',
      'despesas fixas'
    ],
    'relations': [
      'água',
      'luz',
      'energia',
      'gás',
      'internet',
      'wifi',
      'contas fixas',
      'utilidades',
      'despesas fixas',
      'casa',
      'moradia'
    ],
  },
  {
    'id': 29,
    'name': 'Mercado',
    'icon': 'assets/icon-category/mercado.png',
    'color': DefaultColors.vibrantGreen,
    'synonyms': [
      'supermercado',
      'feira',
      'compras do mês',
      'mantimentos',
      'alimentos',
      'mercearia',
      'hortifruti'
    ],
    'relations': [
      'supermercado',
      'feira',
      'compras do mês',
      'mantimentos',
      'alimentos',
      'mercearia',
      'hortifruti',
      'alimentação',
      'casa'
    ],
  },
  {
    'id': 17,
    'name': 'Transporte',
    'icon': 'assets/icon-category/car.png',
    'color': DefaultColors.indigo,
    'synonyms': [
      'locomoção',
      'deslocamento',
      'condução',
      'mobilidade',
      'transporte público',
      'ônibus',
      'metrô',
      'trem'
    ],
    'relations': [
      'locomoção',
      'deslocamento',
      'condução',
      'mobilidade',
      'transporte público',
      'ônibus',
      'metrô',
      'trem',
      'uber',
      'táxi',
      'combustível'
    ],
  },
  {
    'id': 22,
    'name': 'Uber/99',
    'icon': 'assets/icon-category/taxi.png',
    'color': DefaultColors.deepPurple,
    'synonyms': [
      'uber',
      '99',
      'táxi',
      'corrida',
      'aplicativo de transporte',
      'carona',
      'ride'
    ],
    'relations': [
      'uber',
      '99',
      'táxi',
      'corrida',
      'aplicativo de transporte',
      'carona',
      'ride',
      'transporte',
      'locomoção'
    ],
  },
  {
    'id': 28,
    'name': 'Combustível',
    'icon': 'assets/icon-category/combustivel.png',
    'color': DefaultColors.amber,
    'synonyms': [
      'gasolina',
      'etanol',
      'diesel',
      'álcool',
      'gnv',
      'posto',
      'abastecimento'
    ],
    'relations': [
      'gasolina',
      'etanol',
      'diesel',
      'álcool',
      'gnv',
      'posto',
      'abastecimento',
      'carro',
      'transporte',
      'veículo'
    ],
  },
  {
    'id': 32,
    'name': 'Seguro do Carro',
    'icon': 'assets/icon-category/seguros.png',
    'color': DefaultColors.blueGrey,
    'synonyms': [
      'seguro veicular',
      'seguro auto',
      'proteção veicular',
      'seguro automóvel'
    ],
    'relations': [
      'seguro veicular',
      'seguro auto',
      'proteção veicular',
      'seguro automóvel',
      'carro',
      'veículo',
      'transporte'
    ],
  },
  {
    'id': 33,
    'name': 'Multas',
    'icon': 'assets/icon-category/multas.png',
    'color': DefaultColors.redDark,
    'synonyms': [
      'infração',
      'multa de trânsito',
      'penalidade',
      'infração de trânsito'
    ],
    'relations': [
      'infração',
      'multa de trânsito',
      'penalidade',
      'infração de trânsito',
      'carro',
      'veículo',
      'transporte'
    ],
  },
  {
    'id': 1,
    'name': 'Alimentação',
    'icon': 'assets/icon-category/food.png',
    'color': DefaultColors.emeraldBright,
    'synonyms': [
      'comida',
      'refeição',
      'almoço',
      'jantar',
      'café',
      'lanche',
      'nutrição'
    ],
    'relations': [
      'comida',
      'refeição',
      'almoço',
      'jantar',
      'café',
      'lanche',
      'nutrição',
      'restaurante',
      'mercado',
      'delivery'
    ],
  },
  {
    'id': 31,
    'name': 'Lanches',
    'icon': 'assets/icon-category/lanches.png',
    'color': DefaultColors.vibrantYellow,
    'synonyms': [
      'lanchinho',
      'snacks',
      'petisco',
      'merenda',
      'fast food',
      'salgados'
    ],
    'relations': [
      'lanchinho',
      'snacks',
      'petisco',
      'merenda',
      'fast food',
      'salgados',
      'alimentação',
      'comida'
    ],
  },
  {
    'id': 69,
    'name': 'Padaria',
    'icon': 'assets/icon-category/padaria.png',
    'color': DefaultColors.sandyBeige,
    'synonyms': [
      'pão',
      'panificadora',
      'confeitaria',
      'pães',
      'doces',
      'bolos'
    ],
    'relations': [
      'pão',
      'panificadora',
      'confeitaria',
      'pães',
      'doces',
      'bolos',
      'alimentação',
      'mercado'
    ],
  },
  {
    'id': 2,
    'name': 'Assinaturas e serviços',
    'icon': 'assets/icon-category/cartao.png',
    'color': DefaultColors.navy,
    'synonyms': [
      'mensalidade',
      'serviço',
      'assinatura',
      'signature',
      'subscription',
      'plano'
    ],
    'relations': [
      'mensalidade',
      'serviço',
      'assinatura',
      'signature',
      'subscription',
      'plano',
      'streaming',
      'aplicativos'
    ],
  },
  {
    'id': 3,
    'name': 'Bares',
    'icon': 'assets/icon-category/wine.png',
    'color': DefaultColors.burgundy,
    'synonyms': [
      'pub',
      'boteco',
      'bar',
      'happy hour',
      'cervejaria',
      'drinks'
    ],
    'relations': [
      'pub',
      'boteco',
      'bar',
      'happy hour',
      'cervejaria',
      'drinks',
      'lazer',
      'alimentação',
      'entretenimento'
    ],
  },
  {
    'id': 4,
    'name': 'Restaurantes',
    'icon': 'assets/icon-category/restaurante.png',
    'color': DefaultColors.scarlet,
    'synonyms': [
      'restaurante',
      'almoço fora',
      'jantar fora',
      'self-service',
      'buffet',
      'à la carte'
    ],
    'relations': [
      'restaurante',
      'almoço fora',
      'jantar fora',
      'self-service',
      'buffet',
      'à la carte',
      'alimentação',
      'lazer'
    ],
  },
  {
    'id': 6,
    'name': 'Compras',
    'icon': 'assets/icon-category/shopping.png',
    'color': DefaultColors.hotPink,
    'synonyms': [
      'shopping',
      'loja',
      'varejo',
      'compra',
      'aquisição',
      'consumo'
    ],
    'relations': [
      'shopping',
      'loja',
      'varejo',
      'compra',
      'aquisição',
      'consumo',
      'roupas',
      'acessórios',
      'presentes'
    ],
  },
  {
    'id': 34,
    'name': 'Roupas e acessórios',
    'icon': 'assets/icon-category/roupas-e-calcados.png',
    'color': DefaultColors.lavender,
    'synonyms': [
      'vestuário',
      'calçados',
      'sapatos',
      'acessório',
      'moda',
      'bijuteria',
      'joias'
    ],
    'relations': [
      'vestuário',
      'calçados',
      'sapatos',
      'acessório',
      'moda',
      'bijuteria',
      'joias',
      'compras',
      'shopping'
    ],
  },
  {
    'id': 7,
    'name': 'Cuidados pessoais',
    'icon': 'assets/icon-category/skincare.png',
    'color': DefaultColors.pastelPurple,
    'synonyms': [
      'higiene',
      'beleza',
      'cosméticos',
      'skincare',
      'produtos de beleza',
      'cuidados'
    ],
    'relations': [
      'higiene',
      'beleza',
      'cosméticos',
      'skincare',
      'produtos de beleza',
      'cuidados',
      'saúde',
      'bem-estar'
    ],
  },
  {
    'id': 9,
    'name': 'Educação',
    'icon': 'assets/icon-category/education.png',
    'color': DefaultColors.deepPurpleDark,
    'synonyms': [
      'escola',
      'faculdade',
      'curso',
      'universidade',
      'estudo',
      'ensino',
      'material escolar'
    ],
    'relations': [
      'escola',
      'faculdade',
      'curso',
      'universidade',
      'estudo',
      'ensino',
      'material escolar',
      'livros',
      'desenvolvimento'
    ],
  },
  {
    'id': 10,
    'name': 'Família e filhos',
    'icon': 'assets/icon-category/family.png',
    'color': DefaultColors.pastelGreen,
    'synonyms': [
      'crianças',
      'bebê',
      'família',
      'filhos',
      'parentes',
      'criança'
    ],
    'relations': [
      'crianças',
      'bebê',
      'família',
      'filhos',
      'parentes',
      'criança',
      'educação',
      'lazer',
      'saúde'
    ],
  },
  {
    'id': 12,
    'name': 'Lazer e hobbies',
    'icon': 'assets/icon-category/lazer.png',
    'color': DefaultColors.tangerine,
    'synonyms': [
      'diversão',
      'entretenimento',
      'hobby',
      'passatempo',
      'recreação',
      'lazer'
    ],
    'relations': [
      'diversão',
      'entretenimento',
      'hobby',
      'passatempo',
      'recreação',
      'lazer',
      'esporte',
      'cultura',
      'viagem'
    ],
  },
  {
    'id': 13,
    'name': 'Pets',
    'icon': 'assets/icon-category/dog.png',
    'color': DefaultColors.emerald,
    'synonyms': [
      'animais',
      'cachorro',
      'gato',
      'animal de estimação',
      'veterinário',
      'pet shop'
    ],
    'relations': [
      'animais',
      'cachorro',
      'gato',
      'animal de estimação',
      'veterinário',
      'pet shop',
      'saúde',
      'família'
    ],
  },
  {
    'id': 14,
    'name': 'Presentes e doações',
    'icon': 'assets/icon-category/gift.png',
    'color': DefaultColors.vibrantPink,
    'synonyms': [
      'presente',
      'doação',
      'caridade',
      'gift',
      'lembrança',
      'mimo'
    ],
    'relations': [
      'presente',
      'doação',
      'caridade',
      'gift',
      'lembrança',
      'mimo',
      'compras',
      'família',
      'amigos'
    ],
  },
  {
    'id': 15,
    'name': 'Saúde',
    'icon': 'assets/icon-category/saude.png',
    'color': DefaultColors.vibrantTeal,
    'synonyms': [
      'médico',
      'hospital',
      'remédio',
      'consulta',
      'exame',
      'tratamento'
    ],
    'relations': [
      'médico',
      'hospital',
      'remédio',
      'consulta',
      'exame',
      'tratamento',
      'farmácia',
      'bem-estar',
      'plano de saúde'
    ],
  },
  {
    'id': 16,
    'name': 'Trabalho',
    'icon': 'assets/icon-category/work.png',
    'color': DefaultColors.indigoDark,
    'synonyms': [
      'profissional',
      'emprego',
      'escritório',
      'negócios',
      'carreira'
    ],
    'relations': [
      'profissional',
      'emprego',
      'escritório',
      'negócios',
      'carreira',
      'educação',
      'transporte',
      'alimentação'
    ],
  },
  {
    'id': 20,
    'name': 'Vestuário',
    'icon': 'assets/icon-category/roupas.png',
    'color': DefaultColors.plum,
    'synonyms': [
      'roupa',
      'vestimenta',
      'traje',
      'indumentária',
      'vestido',
      'calça'
    ],
    'relations': [
      'roupa',
      'vestimenta',
      'traje',
      'indumentária',
      'vestido',
      'calça',
      'compras',
      'acessórios',
      'moda'
    ],
  },
  {
    'id': 21,
    'name': 'Delivery',
    'icon': 'assets/icon-category/delivery-bike.png',
    'color': DefaultColors.orangeDark,
    'synonyms': [
      'entrega',
      'ifood',
      'rappi',
      'uber eats',
      'pedido',
      'comida delivery'
    ],
    'relations': [
      'entrega',
      'ifood',
      'rappi',
      'uber eats',
      'pedido',
      'comida delivery',
      'alimentação',
      'restaurantes'
    ],
  },
  {
    'id': 23,
    'name': 'Streaming',
    'icon': 'assets/icon-category/streaming.png',
    'color': DefaultColors.electricPurple,
    'synonyms': [
      'netflix',
      'amazon prime',
      'disney+',
      'hbo',
      'spotify',
      'youtube'
    ],
    'relations': [
      'netflix',
      'amazon prime',
      'disney+',
      'hbo',
      'spotify',
      'youtube',
      'entretenimento',
      'assinaturas',
      'lazer'
    ],
  },
  {
    'id': 24,
    'name': 'Farmácia',
    'icon': 'assets/icon-category/farmacia.png',
    'color': DefaultColors.pastelRed,
    'synonyms': [
      'drogaria',
      'medicamentos',
      'remédios',
      'farmácia',
      'medicamento'
    ],
    'relations': [
      'drogaria',
      'medicamentos',
      'remédios',
      'farmácia',
      'medicamento',
      'saúde',
      'bem-estar'
    ],
  },
  {
    'id': 25,
    'name': 'Academia',
    'icon': 'assets/icon-category/academia.png',
    'color': DefaultColors.lightGreen,
    'synonyms': [
      'musculação',
      'fitness',
      'gym',
      'treino',
      'exercício',
      'personal'
    ],
    'relations': [
      'musculação',
      'fitness',
      'gym',
      'treino',
      'exercício',
      'personal',
      'saúde',
      'bem-estar',
      'esporte'
    ],
  },
  {
    'id': 35,
    'name': 'Impostos',
    'icon': 'assets/icon-category/impostos.png',
    'color': DefaultColors.grey,
    'synonyms': [
      'tributos',
      'taxas',
      'iptu',
      'ipva',
      'ir',
      'imposto de renda'
    ],
    'relations': [
      'tributos',
      'taxas',
      'iptu',
      'ipva',
      'ir',
      'imposto de renda',
      'finanças',
      'obrigações'
    ],
  },
  {
    'id': 36,
    'name': 'Plano de Saúde/Seguro de vida',
    'icon': 'assets/icon-category/planodesaude.png',
    'color': DefaultColors.teal,
    'synonyms': [
      'convênio médico',
      'seguro saúde',
      'plano médico',
      'seguro de vida',
      'assistência médica'
    ],
    'relations': [
      'convênio médico',
      'seguro saúde',
      'plano médico',
      'seguro de vida',
      'assistência médica',
      'saúde',
      'bem-estar',
      'seguros'
    ],
  },
  {
    'id': 37,
    'name': 'Financiamento',
    'icon': 'assets/icon-category/financiamentos.png',
    'color': DefaultColors.sapphire,
    'synonyms': [
      'financiamento',
      'prestação',
      'parcela',
      'crédito',
      'financiar'
    ],
    'relations': [
      'financiamento',
      'prestação',
      'parcela',
      'crédito',
      'financiar',
      'dívidas',
      'empréstimos',
      'moradia',
      'carro'
    ],
  },
  {
    'id': 38,
    'name': 'Empréstimos',
    'icon': 'assets/icon-category/emprestimos.png',
    'color': DefaultColors.greenDark,
    'synonyms': [
      'empréstimo',
      'crédito pessoal',
      'dívida',
      'emprestado',
      'crediário'
    ],
    'relations': [
      'empréstimo',
      'crédito pessoal',
      'dívida',
      'emprestado',
      'crediário',
      'financiamento',
      'banco',
      'finanças'
    ],
  },
  {
    'id': 61,
    'name': 'Passagens',
    'icon': 'assets/icon-category/passagens.png',
    'color': DefaultColors.lightBlue,
    'synonyms': [
      'bilhete',
      'ticket',
      'passagem aérea',
      'voo',
      'viagem',
      'transporte'
    ],
    'relations': [
      'bilhete',
      'ticket',
      'passagem aérea',
      'voo',
      'viagem',
      'transporte',
      'lazer',
      'turismo'
    ],
  },
  {
    'id': 62,
    'name': 'Hospedagens',
    'icon': 'assets/icon-category/hoteis.png',
    'color': DefaultColors.gold,
    'synonyms': [
      'hotel',
      'pousada',
      'airbnb',
      'alojamento',
      'estadia',
      'resort'
    ],
    'relations': [
      'hotel',
      'pousada',
      'airbnb',
      'alojamento',
      'estadia',
      'resort',
      'viagem',
      'lazer',
      'turismo'
    ],
  },
  {
    'id': 63,
    'name': 'Alimentação em Viagens',
    'icon': 'assets/icon-category/alimentacaoemviagens.png',
    'color': DefaultColors.coral,
    'synonyms': [
      'refeição viagem',
      'comida viagem',
      'restaurante viagem',
      'alimentação fora'
    ],
    'relations': [
      'refeição viagem',
      'comida viagem',
      'restaurante viagem',
      'alimentação fora',
      'viagem',
      'turismo',
      'lazer'
    ],
  },
  {
    'id': 64,
    'name': 'Passeios',
    'icon': 'assets/icon-category/passeios.png',
    'color': DefaultColors.sunflowerYellow,
    'synonyms': [
      'tour',
      'excursão',
      'turismo',
      'visita',
      'sightseeing',
      'atração turística'
    ],
    'relations': [
      'tour',
      'excursão',
      'turismo',
      'visita',
      'sightseeing',
      'atração turística',
      'viagem',
      'lazer',
      'entretenimento'
    ],
  },
  {
    'id': 65,
    'name': 'Coisas para Casa',
    'icon': 'assets/icon-category/coisasparacasa.png',
    'color': DefaultColors.pastelBlue,
    'synonyms': [
      'utensílios',
      'decoração',
      'móveis',
      'eletrodomésticos',
      'casa',
      'doméstico'
    ],
    'relations': [
      'utensílios',
      'decoração',
      'móveis',
      'eletrodomésticos',
      'casa',
      'doméstico',
      'moradia',
      'compras'
    ],
  },
  {
    'id': 66,
    'name': 'Emergência',
    'icon': 'assets/icon-category/emergency.png',
    'color': DefaultColors.brightRed,
    'synonyms': [
      'urgência',
      'imprevisto',
      'emergencial',
      'socorro',
      'urgente'
    ],
    'relations': [
      'urgência',
      'imprevisto',
      'emergencial',
      'socorro',
      'urgente',
      'saúde',
      'hospital',
      'farmácia'
    ],
  },
  {
    'id': 67,
    'name': 'Aplicativos',
    'icon': 'assets/icon-category/app.png',
    'color': DefaultColors.ultramarineBlue,
    'synonyms': [
      'apps',
      'software',
      'programa',
      'aplicação',
      'app store',
      'play store'
    ],
    'relations': [
      'apps',
      'software',
      'programa',
      'aplicação',
      'app store',
      'play store',
      'tecnologia',
      'assinaturas',
      'serviços'
    ],
  },
  {
    'id': 68,
    'name': 'Jogos Online',
    'icon': 'assets/icon-category/jogosonline.png',
    'color': DefaultColors.neonGreen,
    'synonyms': [
      'games',
      'videogame',
      'jogo',
      'gaming',
      'game pass',
      'steam'
    ],
    'relations': [
      'games',
      'videogame',
      'jogo',
      'gaming',
      'game pass',
      'steam',
      'entretenimento',
      'lazer',
      'tecnologia'
    ],
  },
  {
    'id': 30,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.darkGrey,
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
      'despesas',
      'gastos'
    ],
  },
];

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
    'synonyms': [
      'bônus',
      'prêmio',
      'gratificação',
      'comissão',
      'incentivo'
    ],
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
    'synonyms': [
      'extra',
      'adicional',
      'complemento',
      'bico',
      'ganho extra'
    ],
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
    'synonyms': [
      'transferência',
      'pix',
      'ted',
      'doc',
      'depósito'
    ],
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
    orElse: () => {
      'id': 0,
      'name': '',
      'icon': ''
    },
  );
  if (expenseCategory['id'] != 0) return expenseCategory;

  final incomeCategory = categories_income.firstWhere(
    (category) => category['id'] == id,
    orElse: () => {
      'id': 0,
      'name': '',
      'icon': ''
    },
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
    allCategories = List<Map<String, dynamic>>.from(widget.transactionType == TransactionType.receita ? categories_income : categories_expenses);
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
            return synonyms.map((s) => s.toLowerCase()).any((s) => s.contains(searchQuery));
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
