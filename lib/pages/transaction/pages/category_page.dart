// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:organizamais/utils/color.dart';

import '../../../ads_banner/ads_banner.dart';
import '../../../model/transaction_model.dart';
import '../../../controller/transaction_controller.dart';
import '../../../utils/snackbar_helper.dart'; // Import added

final List<Map<String, dynamic>> categories_expenses = [
  // ========== MORADIA E CASA ==========
  {
    'id': 5,
    'name': 'Moradia',
    'icon': 'assets/icon-category/home.png',
    'color': DefaultColors.blue,
    'macrocategoria': 'Moradia e Casa',
    'synonyms': ['casa', 'aluguel', 'hipoteca', 'condomínio'],
    'relations': ['habitação', 'imóvel', 'residência']
  },
  {
    'id': 26,
    'name': 'Contas (água, luz, gás, internet)',
    'icon': 'assets/icon-category/contas.png',
    'color': DefaultColors.skyBlue,
    'macrocategoria': 'Moradia e Casa',
    'synonyms': ['utilidades', 'energia', 'wifi', 'conta de luz']
  },
  {
    'id': 65,
    'name': 'Coisas para Casa',
    'icon': 'assets/icon-category/coisasparacasa.png',
    'color': DefaultColors.pastelBlue,
    'macrocategoria': 'Moradia e Casa',
    'synonyms': ['móveis', 'decoração', 'eletrodomésticos', 'utensílios']
  },
  {
    'id': 19,
    'name': 'Manutenção e reparos',
    'icon': 'assets/icon-category/manutencao.png',
    'color': DefaultColors.titanium,
    'macrocategoria': 'Moradia e Casa',
    'synonyms': ['reforma', 'conserto', 'reparo', 'serviços domésticos']
  },

  {
    'id': 90,
    'name': 'Condomínio',
    'icon': 'assets/icon-category/condominio.png',
    'color': DefaultColors.azure,
    'macrocategoria': 'Moradia e Casa',
    'synonyms': ['taxa condominial', 'condomínio', 'síndico']
  },

  // ========== ALIMENTAÇÃO ==========
  {
    'id': 1,
    'name': 'Alimentação',
    'icon': 'assets/icon-category/food.png',
    'color': DefaultColors.emeraldBright,
    'macrocategoria': 'Alimentação',
    'synonyms': ['comida', 'supermercado', 'feira', 'despensa']
  },
  {
    'id': 29,
    'name': 'Mercado',
    'icon': 'assets/icon-category/mercado.png',
    'color': DefaultColors.vibrantGreen,
    'macrocategoria': 'Alimentação',
    'synonyms': ['compra do mês', 'hortifruti', 'despensa']
  },
  {
    'id': 4,
    'name': 'Restaurantes',
    'icon': 'assets/icon-category/restaurante.png',
    'color': DefaultColors.scarlet,
    'macrocategoria': 'Alimentação',
    'synonyms': ['jantar fora', 'delivery', 'fast food']
  },
  {
    'id': 21,
    'name': 'Delivery',
    'icon': 'assets/icon-category/delivery-bike.png',
    'color': DefaultColors.orangeDark,
    'macrocategoria': 'Alimentação',
    'synonyms': ['Ifood', 'Uber Eats', 'comida pronta']
  },
  {
    'id': 31,
    'name': 'Lanches',
    'icon': 'assets/icon-category/lanches.png',
    'color': DefaultColors.vibrantYellow,
    'macrocategoria': 'Alimentação',
    'synonyms': ['petisco', 'fast food', 'salgadinho']
  },
  {
    'id': 69,
    'name': 'Padaria',
    'icon': 'assets/icon-category/padaria.png',
    'color': DefaultColors.sandyBeige,
    'macrocategoria': 'Alimentação',
    'synonyms': ['pão', 'confeitaria', 'doces']
  },

  // ========== TRANSPORTE ==========
  {
    'id': 17,
    'name': 'Transporte',
    'icon': 'assets/icon-category/car.png',
    'color': DefaultColors.indigo,
    'macrocategoria': 'Transporte',
    'synonyms': ['ônibus', 'metrô', 'combustível', 'táxi', 'carro']
  },
  {
    'id': 28,
    'name': 'Combustível',
    'icon': 'assets/icon-category/combustivel.png',
    'color': DefaultColors.amber,
    'macrocategoria': 'Transporte',
    'synonyms': ['gasolina', 'posto', 'abastecimento']
  },
  {
    'id': 22,
    'name': 'Transporte por Aplicativo',
    'icon': 'assets/icon-category/taxi.png',
    'color': DefaultColors.deepPurple,
    'macrocategoria': 'Transporte',
    'synonyms': ['aplicativo de transporte', 'carona', 'uber', '99', 'inDrive']
  },
  {
    'id': 92,
    'name': 'Manutenção do carro',
    'icon': 'assets/icon-category/manutencao-carro.png',
    'color': DefaultColors.steelBlue,
    'macrocategoria': 'Transporte',
    'synonyms': ['revisão', 'oficina', 'mecânico', 'troca de óleo']
  },
  {
    'id': 102,
    'name': 'Acessórios para o carro',
    'icon': 'assets/icon-category/acessorios-carro.png',
    'color': DefaultColors.graphite,
    'macrocategoria': 'Transporte',
    'synonyms': [
      'acessório de carro',
      'tapete',
      'capa',
      'calha de chuva',
      'organizador'
    ]
  },
  {
    'id': 93,
    'name': 'Transporte público',
    'icon': 'assets/icon-category/transprote-puiblico.png',
    'color': DefaultColors.cerulean,
    'macrocategoria': 'Transporte',
    'synonyms': ['ônibus', 'metrô', 'trem', 'bilhete']
  },
  {
    'id': 71,
    'name': 'Pedágio/Estacionamento',
    'icon': 'assets/icon-category/pedagios.png',
    'color': DefaultColors.slateGrey,
    'macrocategoria': 'Transporte',
    'synonyms': ['tarifa rodoviária', 'estrada']
  },
  {
    'id': 33,
    'name': 'Multas',
    'icon': 'assets/icon-category/multas.png',
    'color': DefaultColors.redDark,
    'macrocategoria': 'Transporte',
    'synonyms': ['infração', 'trânsito', 'penalidade']
  },
  {
    'id': 70,
    'name': 'IPVA',
    'icon': 'assets/icon-category/ipva.png',
    'color': DefaultColors.cobalt,
    'macrocategoria': 'Transporte',
    'synonyms': ['licenciamento', 'taxa veicular']
  },
  {
    'id': 32,
    'name': 'Seguro do Carro',
    'icon': 'assets/icon-category/seguros.png',
    'color': DefaultColors.blueGrey,
    'macrocategoria': 'Transporte',
    'synonyms': ['seguro auto', 'proteção veicular']
  },

  // ========== SAÚDE E BEM-ESTAR ==========
  {
    'id': 15,
    'name': 'Saúde',
    'icon': 'assets/icon-category/saude.png',
    'color': DefaultColors.vibrantTeal,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['médico', 'hospital', 'plano de saúde']
  },
  {
    'id': 86, // NOVA
    'name': 'Exames',
    'icon': 'assets/icon-category/exames.png',
    'color': DefaultColors.lightBlue,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['produtos de limpeza', 'faxina', 'empregada doméstica']
  },
  {
    'id': 24,
    'name': 'Farmácia',
    'icon': 'assets/icon-category/farmacia.png',
    'color': DefaultColors.pastelRed,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['remédio', 'medicamento', 'drogaria']
  },
  {
    'id': 36,
    'name': 'Plano de Saúde/Seguro de vida',
    'icon': 'assets/icon-category/planodesaude.png',
    'color': DefaultColors.teal,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['convênio médico', 'assistência médica']
  },
  {
    'id': 87, // NOVA
    'name': 'Consultas Médicas',
    'icon': 'assets/icon-category/consultas-medicas.png',
    'color': DefaultColors.indigoLight,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['médico', 'dentista', 'psicólogo', 'terapia']
  },
  {
    'id': 97,
    'name': 'Psicólogo / Terapia',
    'icon': 'assets/icon-category/consultas.png',
    'color': DefaultColors.aquamarine,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['psicólogo', 'terapia', 'psicoterapia']
  },
  {
    'id': 98,
    'name': 'Dentista',
    'icon': 'assets/icon-category/dentinsta.png',
    'color': DefaultColors.jade,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['odontologia', 'dentário', 'tratamento dental']
  },
  {
    'id': 88, // NOVA
    'name': 'Salão/Barbearia',
    'icon': 'assets/icon-category/salao.png',
    'color': DefaultColors.pink,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['cabeleireiro', 'corte de cabelo', 'beleza', 'estética']
  },
  {
    'id': 7,
    'name': 'Cuidados pessoais',
    'icon': 'assets/icon-category/skincare.png',
    'color': DefaultColors.pastelPurple,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['cosméticos', 'higiene', 'perfumaria']
  },
  {
    'id': 25,
    'name': 'Academia',
    'icon': 'assets/icon-category/academia.png',
    'color': DefaultColors.lightGreen,
    'macrocategoria': 'Saúde e Bem-estar',
    'synonyms': ['ginástica', 'treino', 'fitness']
  },

  // ========== EDUCAÇÃO ==========
  {
    'id': 9,
    'name': 'Educação',
    'icon': 'assets/icon-category/education.png',
    'color': DefaultColors.deepPurpleDark,
    'macrocategoria': 'Educação',
    'synonyms': ['escola', 'curso', 'faculdade', 'material escolar']
  },
  {
    'id': 76,
    'name': 'Livros/Revistas',
    'icon': 'assets/icon-category/livros.png',
    'color': DefaultColors.earthBrown,
    'macrocategoria': 'Educação',
    'synonyms': ['leitura', 'biblioteca', 'ebook']
  },
  {
    'id': 94,
    'name': 'Escola / Material escolar',
    'icon': 'assets/icon-category/escola.png',
    'color': DefaultColors.periwinkle,
    'macrocategoria': 'Educação',
    'synonyms': ['material escolar', 'uniforme', 'mensalidade escolar']
  },
  {
    'id': 96,
    'name': 'Atividades extracurriculares (curso, esporte, música)',
    'icon': 'assets/icon-category/atividade-extracurriculares.png',
    'color': DefaultColors.orchid,
    'macrocategoria': 'Educação',
    'synonyms': ['curso', 'esporte', 'música', 'aula particular']
  },

  // ========== LAZER E ENTRETENIMENTO ==========
  {
    'id': 12,
    'name': 'Lazer e hobbies',
    'icon': 'assets/icon-category/lazer.png',
    'color': DefaultColors.tangerine,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['cinema', 'parque', 'passeio', 'hobby']
  },
  {
    'id': 3,
    'name': 'Bares',
    'icon': 'assets/icon-category/wine.png',
    'color': DefaultColors.burgundy,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['happy hour', 'drinks', 'boteco']
  },
  {
    'id': 75,
    'name': 'Cinema',
    'icon': 'assets/icon-category/cinema.png',
    'color': DefaultColors.amethyst,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['Netflix', 'ingresso', 'filme']
  },
  {
    'id': 23,
    'name': 'Streaming',
    'icon': 'assets/icon-category/streaming.png',
    'color': DefaultColors.electricPurple,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['Spotify', 'Disney+', 'assinatura']
  },
  {
    'id': 68,
    'name': 'Jogos Online',
    'icon': 'assets/icon-category/jogosonline.png',
    'color': DefaultColors.neonGreen,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['videogame', 'steam', 'game pass']
  },
  {
    'id': 74,
    'name': 'Viagens',
    'icon': 'assets/icon-category/viagens.png',
    'color': DefaultColors.oceanBlue,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['férias', 'turismo', 'passeio']
  },
  {
    'id': 62,
    'name': 'Hospedagens',
    'icon': 'assets/icon-category/hoteis.png',
    'color': DefaultColors.gold,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['hotel', 'Airbnb', 'resort']
  },
  {
    'id': 61,
    'name': 'Passagens',
    'icon': 'assets/icon-category/passagens.png',
    'color': DefaultColors.lightBlue,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['avião', 'ônibus', 'viagem']
  },
  {
    'id': 63,
    'name': 'Alimentação em Viagens',
    'icon': 'assets/icon-category/alimentacaoemviagens.png',
    'color': DefaultColors.coral,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['comida de viagem', 'restaurante turístico']
  },
  {
    'id': 64,
    'name': 'Passeios',
    'icon': 'assets/icon-category/passeios.png',
    'color': DefaultColors.sunflowerYellow,
    'macrocategoria': 'Lazer e Entretenimento',
    'synonyms': ['turismo', 'ponto turístico', 'excursão']
  },

  // ========== COMPRAS ==========
  {
    'id': 6,
    'name': 'Compras',
    'icon': 'assets/icon-category/shopping.png',
    'color': DefaultColors.hotPink,
    'macrocategoria': 'Compras',
    'synonyms': ['shopping', 'loja', 'e-commerce']
  },
  {
    'id': 20,
    'name': 'Vestuário',
    'icon': 'assets/icon-category/roupas.png',
    'color': DefaultColors.plum,
    'macrocategoria': 'Compras',
    'synonyms': ['roupa', 'moda', 'vestido']
  },
  {
    'id': 34,
    'name': 'Roupas e acessórios',
    'icon': 'assets/icon-category/roupas-e-calcados.png',
    'color': DefaultColors.lavender,
    'macrocategoria': 'Compras',
    'synonyms': ['calçados', 'bolsas', 'joias']
  },
  {
    'id': 89,
    'name': 'Eletrônicos',
    'icon': 'assets/icon-category/eletronicos.png',
    'color': DefaultColors.jungleGreen,
    'macrocategoria': 'Compras',
    'synonyms': [
      'tecnologia',
      'gadgets',
      'computador',
      'celular',
      'notebook',
      'tablet',
      'smartphone',
      'TV',
      'televisão',
      'fone',
      'headphone'
    ]
  },
  {
    'id': 14,
    'name': 'Presentes',
    'icon': 'assets/icon-category/gift.png',
    'color': DefaultColors.vibrantPink,
    'macrocategoria': 'Compras',
    'synonyms': ['lembrança', 'mimo', 'aniversário']
  },

  // ========== PETS ==========
  {
    'id': 13,
    'name': 'Pets',
    'icon': 'assets/icon-category/dog.png',
    'color': DefaultColors.emerald,
    'macrocategoria': 'Pets',
    'synonyms': ['animal', 'veterinário', 'pet shop']
  },
  {
    'id': 99,
    'name': 'Veterinário',
    'icon': 'assets/icon-category/veterinario.png',
    'color': DefaultColors.moss,
    'macrocategoria': 'Pets',
    'synonyms': ['consulta pet', 'clínica veterinária']
  },
  // {
  //   'id': 78,
  //   'name': 'Pet (Veterinário/Ração)',
  //   'icon': 'assets/icon-category/pet.png',
  //   'color': DefaultColors.jungleGreen,
  //   'macrocategoria': 'Pets',
  //   'synonyms': ['gato', 'cachorro', 'animal de estimação']
  // },

  // ========== FINANÇAS ==========
  {
    'id': 35,
    'name': 'Impostos',
    'icon': 'assets/icon-category/impostos.png',
    'color': DefaultColors.grey,
    'macrocategoria': 'Finanças',
    'synonyms': ['IPTU', 'IRPF', 'tributo']
  },
  {
    'id': 91,
    'name': 'IPTU',
    'icon': 'assets/icon-category/iptu.png',
    'color': DefaultColors.vermilion,
    'macrocategoria': 'Finanças',
    'synonyms': ['imposto imobiliário', 'tributo municipal']
  },
  {
    'id': 37,
    'name': 'Financiamento',
    'icon': 'assets/icon-category/financiamentos.png',
    'color': DefaultColors.sapphire,
    'macrocategoria': 'Finanças',
    'synonyms': ['empréstimo', 'parcela', 'crédito']
  },
  {
    'id': 38,
    'name': 'Empréstimos',
    'icon': 'assets/icon-category/emprestimos.png',
    'color': DefaultColors.greenDark,
    'macrocategoria': 'Finanças',
    'synonyms': ['dívida', 'crediário', 'consignado']
  },
  {
    'id': 79,
    'name': 'Taxas',
    'icon': 'assets/icon-category/taxas.png',
    'color': DefaultColors.magenta,
    'macrocategoria': 'Finanças',
    'synonyms': ['tarifa', 'anuidade', 'juros']
  },
  {
    'id': 101,
    'name': 'Cartão de crédito (fatura) Juros',
    'icon': 'assets/icon-category/fatura.png',
    'color': DefaultColors.charcoal,
    'macrocategoria': 'Finanças',
    'synonyms': ['cartão de crédito', 'fatura', 'juros', 'encargos', 'anuidade']
  },
  {
    'id': 2,
    'name': 'Assinaturas e serviços',
    'icon': 'assets/icon-category/cartao.png',
    'color': DefaultColors.navy,
    'macrocategoria': 'Finanças',
    'synonyms': ['mensalidade', 'plano', 'serviço']
  },
  {
    'id': 67,
    'name': 'Aplicativos',
    'icon': 'assets/icon-category/app.png',
    'color': DefaultColors.ultramarineBlue,
    'macrocategoria': 'Finanças',
    'synonyms': ['software', 'app pago', 'assinatura']
  },
  {
    'id': 80,
    'name': 'Seguros',
    'icon': 'assets/icon-category/seguros.png',
    'color': DefaultColors.topaz,
    'macrocategoria': 'Finanças',
    'synonyms': ['proteção', 'apólice', 'seguro residencial']
  },

  // ========== FAMÍLIA ==========
  {
    'id': 10,
    'name': 'Família e filhos',
    'icon': 'assets/icon-category/family.png',
    'color': DefaultColors.pastelGreen,
    'macrocategoria': 'Família',
    'synonyms': ['criança', 'escola', 'creche']
  },
  {
    'id': 77,
    'name': 'Doações/Caridade',
    'icon': 'assets/icon-category/doacoes.png',
    'color': DefaultColors.rosyPink,
    'macrocategoria': 'Família',
    'synonyms': ['ONG', 'solidariedade', 'contribuição']
  },
  {
    'id': 95,
    'name': 'Creche / Baba',
    'icon': 'assets/icon-category/escola.png',
    'color': DefaultColors.cinnamon,
    'macrocategoria': 'Família',
    'synonyms': ['creche', 'cuidado infantil']
  },
  {
    'id': 100,
    'name': 'Brinquedos e acessórios',
    'icon': 'assets/icon-category/gift.png',
    'color': DefaultColors.saffron,
    'macrocategoria': 'Família',
    'synonyms': ['brinquedos', 'acessórios infantis', 'jogos']
  },

  // ========== TRABALHO ==========
  {
    'id': 16,
    'name': 'Trabalho',
    'icon': 'assets/icon-category/work.png',
    'color': DefaultColors.indigoDark,
    'macrocategoria': 'Trabalho',
    'synonyms': ['escritório', 'material', 'profissional']
  },

  // ========== IMPREVISTOS ==========
  {
    'id': 66,
    'name': 'Emergência',
    'icon': 'assets/icon-category/emergency.png',
    'color': DefaultColors.brightRed,
    'macrocategoria': 'Imprevistos',
    'synonyms': ['imprevisto', 'urgência', 'socorro']
  },

  // ========== OUTROS ==========
  {
    'id': 30,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.darkGrey,
    'macrocategoria': 'Outros',
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
    'macrocategoria': 'Renda do Trabalho',
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
    'macrocategoria': 'Investimentos',
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
    'macrocategoria': 'Renda do Trabalho',
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
    'macrocategoria': 'Renda Extra',
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
    'name': 'Transferências / PIX / TED',
    'icon': 'assets/icon-category/transfer.png',
    'color': Colors.blue,
    'macrocategoria': 'Transferências',
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
    'macrocategoria': 'Renda Extra',
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
    'macrocategoria': 'Reembolsos e Compensações',
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
    'macrocategoria': 'Reembolsos e Compensações',
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
    'macrocategoria': 'Investimentos',
    'synonyms': ['imóvel', 'renda imobiliária'],
    'relations': ['investimento', 'moradia'],
  },
  {
    'id': 82,
    'name': 'Dividendos',
    'icon': 'assets/icon-category/dividendos.png',
    'color': DefaultColors.forestGreen, // Nova cor
    'macrocategoria': 'Investimentos',
    'synonyms': ['investimentos', 'ações'],
    'relations': ['renda passiva', 'finanças'],
  },
  {
    'id': 83,
    'name': 'Venda de Itens Usados',
    'icon': 'assets/icon-category/vendas.png',
    'color': DefaultColors.tangerine, // Nova cor
    'macrocategoria': 'Renda Extra',
    'synonyms': ['brechó', 'usado'],
    'relations': ['compras', 'renda extra'],
  },
  {
    'id': 84,
    'name': 'Reembolsos',
    'icon': 'assets/icon-category/reembolso.png',
    'color': DefaultColors.seaGreen, // Nova cor
    'macrocategoria': 'Reembolsos e Compensações',
    'synonyms': ['devolução', 'estorno'],
    'relations': ['compras', 'finanças'],
  },
  {
    'id': 85,
    'name': 'Pensão Alimentícia',
    'icon': 'assets/icon-category/pensao.png',
    'color': DefaultColors.oliveGreen, // Nova cor
    'macrocategoria': 'Família',
    'synonyms': ['alimentos', 'judicial'],
    'relations': ['família', 'filhos'],
  },
  {
    'id': 55,
    'name': 'Outros',
    'icon': 'assets/icon-category/outros.png',
    'color': DefaultColors.grey,
    'macrocategoria': 'Outros',
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

List<Map<String, dynamic>> getCategoriesByMacrocategoria(String macrocategoria,
    {bool isIncome = false}) {
  final List<Map<String, dynamic>> targetCategories =
      isIncome ? categories_income : categories_expenses;

  return targetCategories
      .where((category) =>
          category['macrocategoria'].toString().toLowerCase() ==
          macrocategoria.toLowerCase())
      .toList();
}

List<String> getAllMacrocategorias({bool isIncome = false}) {
  final List<Map<String, dynamic>> targetCategories =
      isIncome ? categories_income : categories_expenses;

  return targetCategories
      .map((category) => category['macrocategoria'].toString())
      .toSet()
      .toList();
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
  late List<String> macrocategorias;
  String? selectedMacrocategoria;

  @override
  void initState() {
    super.initState();
    allCategories = List<Map<String, dynamic>>.from(
        widget.transactionType == TransactionType.receita
            ? categories_income
            : categories_expenses);
    filteredCategories = List<Map<String, dynamic>>.from(allCategories);

    // Get all unique macrocategorias
    macrocategorias = getAllMacrocategorias(
        isIncome: widget.transactionType == TransactionType.receita);

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
      List<Map<String, dynamic>> categoriesToFilter = allCategories;

      // First filter by macrocategoria if selected
      if (selectedMacrocategoria != null) {
        categoriesToFilter = allCategories
            .where((category) =>
                category['macrocategoria'].toString() == selectedMacrocategoria)
            .toList();
      }

      if (query.isEmpty) {
        // Show filtered categories by macrocategoria or all if none selected
        filteredCategories =
            List<Map<String, dynamic>>.from(categoriesToFilter);
      } else {
        // Filter categories based on name, synonyms and macrocategoria
        filteredCategories = categoriesToFilter.where((category) {
          final name = category['name'].toString().toLowerCase();
          final macrocategoria =
              category['macrocategoria'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();

          // Check if name contains query
          if (name.contains(searchQuery)) {
            return true;
          }

          // Check if macrocategoria contains query
          if (macrocategoria.contains(searchQuery)) {
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

  void _selectMacrocategoria(String? macrocategoria) {
    setState(() {
      selectedMacrocategoria = macrocategoria;
      _filterCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TransactionController transactionController =
        Get.find<TransactionController>();

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
          AdsBanner(),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 2.h,
              horizontal: 12.w,
            ),
            child: TextField(
              controller: searchController,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
              decoration: InputDecoration(
                hintText: 'Pesquisar categoria',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
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
          // Macrocategorias chips
          SizedBox(
            height: 10.h,
          ),

          Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(vertical: 6.h),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                ...macrocategorias.map((macrocategoria) => Container(
                      margin: EdgeInsets.only(right: 8.w),
                      child: FilterChip(
                        label: Text(
                          macrocategoria,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                          ),
                        ),
                        // selected: selectedMacrocategoria == macrocategoria,
                        onSelected: (selected) {
                          _selectMacrocategoria(
                              selected ? macrocategoria : null);
                        },
                        backgroundColor: theme.cardColor,
                        selectedColor: theme.cardColor,
                        side: BorderSide(
                          color: selectedMacrocategoria == macrocategoria
                              ? DefaultColors.greenDark
                              : theme.cardColor,
                        ),
                      ),
                    )),
              ],
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
                      vertical: 2.h,
                      horizontal: 20.w,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final int categoryId = (category['id'] as int);
                      final TransactionType currentType =
                          widget.transactionType ?? TransactionType.despesa;

                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 12.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 4.w,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(
                            14.r,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 26.r,
                            backgroundColor: DefaultColors.grey.withOpacity(
                              .1,
                            ),
                            child: Image.asset(
                              category['icon'],
                              height: 24.h,
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
                          subtitle: Obx(() {
                            // Rebuild when Firestore transactions change
                            transactionController.transactionRx;

                            final DateTime now = DateTime.now();
                            final int cm = now.month;
                            final int cy = now.year;

                            final items = transactionController.transaction
                                .where((t) =>
                                    t.category == categoryId &&
                                    t.type == currentType)
                                .toList();

                            final int totalCount = items.length;
                            final int monthCount = items.where((t) {
                              if (t.paymentDay == null) return false;
                              try {
                                final d = DateTime.parse(t.paymentDay!);
                                return d.month == cm && d.year == cy;
                              } catch (_) {
                                return false;
                              }
                            }).length;

                            return Text(
                              '$monthCount transações nesse mês / $totalCount transações no total',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.hintColor,
                              ),
                            );
                          }),
                          onTap: () {
                            // Fechar qualquer snackbar aberto de forma segura
                            SnackbarHelper.closeAllSnackbars();
                            Navigator.of(context).pop(category['id']);
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
