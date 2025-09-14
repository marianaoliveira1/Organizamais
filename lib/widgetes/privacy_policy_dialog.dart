import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showPrivacyPolicyDialog(BuildContext context) async {
  final theme = Theme.of(context);
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          'Política de Privacidade',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        content: SizedBox(
          width: 1.0.sw,
          child: SingleChildScrollView(
            child: Text(
              'Política Privacidade\n\n'
              'A sua privacidade é importante para nós. É política do Organiza+ respeitar a sua privacidade em relação a qualquer informação sua que possamos coletar no site Organiza+, e outros sites que possuímos e operamos.\n\n'
              'Solicitamos informações pessoais apenas quando realmente precisamos delas para lhe fornecer um serviço. Fazemo-lo por meios justos e legais, com o seu conhecimento e consentimento. Também informamos por que estamos coletando e como será usado.\n\n'
              'Apenas retemos as informações coletadas pelo tempo necessário para fornecer o serviço solicitado. Quando armazenamos dados, protegemos dentro de meios comercialmente aceitáveis ​​para evitar perdas e roubos, bem como acesso, divulgação, cópia, uso ou modificação não autorizados.\n\n'
              'Não compartilhamos informações de identificação pessoal publicamente ou com terceiros, exceto quando exigido por lei.\n\n'
              'O nosso site pode ter links para sites externos que não são operados por nós. Esteja ciente de que não temos controle sobre o conteúdo e práticas desses sites e não podemos aceitar responsabilidade por suas respectivas políticas de privacidade.\n\n'
              'Você é livre para recusar a nossa solicitação de informações pessoais, entendendo que talvez não possamos fornecer alguns dos serviços desejados.\n\n'
              'O uso continuado de nosso site será considerado como aceitação de nossas práticas em torno de privacidade e informações pessoais. Se você tiver alguma dúvida sobre como lidamos com dados do usuário e informações pessoais, entre em contacto connosco.\n\n'
              'O serviço Google AdSense que usamos para veicular publicidade usa um cookie DoubleClick para veicular anúncios mais relevantes em toda a Web e limitar o número de vezes que um determinado anúncio é exibido para você.\n'
              'Para mais informações sobre o Google AdSense, consulte as FAQs oficiais sobre privacidade do Google AdSense.\n'
              'Utilizamos anúncios para compensar os custos de funcionamento deste site e fornecer financiamento para futuros desenvolvimentos. Os cookies de publicidade comportamental usados ​​por este site foram projetados para garantir que você forneça os anúncios mais relevantes sempre que possível, rastreando anonimamente seus interesses e apresentando coisas semelhantes que possam ser do seu interesse.\n'
              'Vários parceiros anunciam em nosso nome e os cookies de rastreamento de afiliados simplesmente nos permitem ver se nossos clientes acessaram o site através de um dos sites de nossos parceiros, para que possamos creditá-los adequadamente e, quando aplicável, permitir que nossos parceiros afiliados ofereçam qualquer promoção que pode fornecê-lo para fazer uma compra.\n\n'
              'Compromisso do Usuário\n\n'
              'O usuário se compromete a fazer uso adequado dos conteúdos e da informação que o Organiza+ oferece no site e com caráter enunciativo, mas não limitativo:\n\n'
              'A) Não se envolver em atividades que sejam ilegais ou contrárias à boa fé a à ordem pública;\n'
              'B) Não difundir propaganda ou conteúdo de natureza racista, xenofóbica, jogos de sorte ou azar, qualquer tipo de pornografia ilegal, de apologia ao terrorismo ou contra os direitos humanos;\n'
              'C) Não causar danos aos sistemas físicos (hardwares) e lógicos (softwares) do Organiza+, de seus fornecedores ou terceiros, para introduzir ou disseminar vírus informáticos ou quaisquer outros sistemas de hardware ou software que sejam capazes de causar danos anteriormente mencionados.\n\n'
              'Mais informações\n\n'
              'Esperemos que esteja esclarecido e, como mencionado anteriormente, se houver algo que você não tem certeza se precisa ou não, geralmente é mais seguro deixar os cookies ativados, caso interaja com um dos recursos que você usa em nosso site.',
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.35,
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fechar',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}
