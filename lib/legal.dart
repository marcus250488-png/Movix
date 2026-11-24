import 'package:flutter/material.dart';

class DocumentosMovixTela extends StatelessWidget {
  const DocumentosMovixTela({super.key});

  void _abrir(BuildContext context, String titulo, List<String> secoes) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _DocumentoMovixTela(documentoTitulo: titulo, secoes: secoes),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Documentos e segurança', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Color(0xFFE8DCC8)))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _painel(const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Documentos em revisão', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        SizedBox(height: 7),
        Text('O Movix está em desenvolvimento. Estes textos descrevem o funcionamento atual e são uma minuta; antes de qualquer distribuição pública, o responsável pelo aplicativo deverá revisar, preencher os dados de contato e validar os documentos.', style: TextStyle(color: const Color(0xFFB3A394), height: 1.45)),
      ])),
      const SizedBox(height: 12),
      _item(context, Icons.description_outlined, 'Termos de Uso', 'Regras de utilização, limites e segurança.', () => _abrir(context, 'Termos de Uso', _termos)),
      _item(context, Icons.privacy_tip_outlined, 'Política de Privacidade', 'Dados locais, permissões e serviços externos.', () => _abrir(context, 'Política de Privacidade', _privacidade)),
      _item(context, Icons.health_and_safety_outlined, 'Aviso de saúde e exercícios', 'Orientações para uso responsável.', () => _abrir(context, 'Aviso de saúde e exercícios', _saude)),
      const SizedBox(height: 8),
      const Text('Contato do responsável: ainda precisa ser informado e incluído nesta documentação antes da distribuição pública.', style: TextStyle(color: const Color(0xFFB3A394), fontSize: 12, height: 1.4)),
    ]),
  );

  Widget _item(BuildContext context, IconData icon, String title, String subtitle, VoidCallback tap) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: const Color(0xFF241116),
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(icon, color: const Color(0xFFA3203F), size: 25),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFFB3A394), fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFB3A394)),
        onTap: tap,
      ),
    ),
  );

  Widget _painel(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF241116),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .10)),
    ),
    child: child,
  );
}

class _DocumentoMovixTela extends StatelessWidget {
  final String documentoTitulo;
  final List<String> secoes;
  const _DocumentoMovixTela({required this.documentoTitulo, required this.secoes});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(documentoTitulo, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: Color(0xFFE8DCC8)))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      for (var i=0; i<secoes.length; i+=2) ...[
        Text(secoes[i], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 6),
        Text(secoes[i+1], style: const TextStyle(color: const Color(0xFFB3A394), height: 1.5)),
        const SizedBox(height: 18),
      ],
      const Text('Minuta de desenvolvimento — revisar com o responsável pelo Movix antes de disponibilizar publicamente.', style: TextStyle(fontSize: 11, color: const Color(0xFFB3A394))),
    ]),
  );
}

const List<String> _termos = [
  '1. Sobre o Movix',
  'O Movix é uma ferramenta de apoio à organização de treinos, registro de atividades, acompanhamento de evolução e consulta de informações nutricionais. O aplicativo não substitui profissionais de educação física, médicos, nutricionistas ou outros profissionais habilitados.',
  '2. Uso responsável',
  'O usuário é responsável por avaliar sua condição e utilizar o aplicativo de forma compatível com sua capacidade. Interrompa a atividade se sentir dor, tontura, falta de ar incomum ou mal-estar e procure orientação profissional quando necessário.',
  '3. Informações e resultados',
  'Sugestões, estimativas, cálculos e registros são informativos. Resultados variam conforme cada pessoa e não são garantidos. Confira cargas, repetições, medidas e dados inseridos antes de tomar decisões.',
  '4. Dados e cópias de segurança',
  'Na versão local-first, os registros principais ficam no armazenamento do aparelho. O usuário pode exportar os dados pela função disponível no aplicativo e é responsável por guardar a cópia em local seguro. Desinstalar o aplicativo ou limpar seus dados pode causar perda dos registros locais.',
  '5. Serviços de terceiros',
  'Algumas funções opcionais consultam serviços externos: a busca de alimentos pode enviar o termo pesquisado ao Open Food Facts; a busca de academias próximas pode enviar coordenadas aproximadas/atuais e uma consulta ao serviço Overpass/OpenStreetMap. Esses serviços têm seus próprios termos e políticas.',
  '6. Disponibilidade e alterações',
  'O aplicativo pode receber correções, mudanças ou interrupções de funcionalidades durante o desenvolvimento. Recursos Premium exibidos como exclusivos ainda não representam uma contratação ativa nesta versão.',
  '7. Responsável e contato',
  'O nome/identificação do responsável pelo Movix, endereço de contato e canal para solicitações deverão ser preenchidos pelo responsável antes da distribuição pública. Não use esta minuta como documento final sem essa revisão.',
];

const List<String> _privacidade = [
  '1. Situação desta versão',
  'Esta versão funciona prioritariamente de forma local e não exige criação de conta para usar as funções principais. Login Google e sincronização em nuvem não estão ativos nesta etapa. Os pacotes técnicos relacionados a serviços futuros não significam que esses serviços estejam sendo utilizados para sincronizar os dados nesta versão.',
  '2. Dados armazenados no aparelho',
  'O aplicativo pode guardar localmente plano e histórico de treinos, exercícios personalizados, cargas, séries, avaliações e medidas corporais, metas de água e passos, registros de alimentação, preferências e progresso. Esses dados são usados para apresentar as funções do próprio aplicativo.',
  '3. Permissões',
  'Atividade física é solicitada para contar passos pelo sensor do aparelho. Localização é solicitada somente quando o usuário escolhe buscar academias próximas. Internet é utilizada nas buscas online de alimentos e academias. O usuário pode negar permissões; algumas funções opcionais deixam de funcionar, mas o uso principal continua disponível.',
  '4. Serviços externos opcionais',
  'Na busca online de alimentos, o termo digitado é enviado ao Open Food Facts para consultar produtos e informações nutricionais. Na busca de academias próximas, a localização do aparelho é usada para consultar o Overpass API/OpenStreetMap. A política de privacidade desses provedores também se aplica ao tratamento realizado por eles. Não digite dados pessoais desnecessários nos campos de busca.',
  '5. Compartilhamento e exportação',
  'O Movix não envia os registros locais de treino, medidas ou diário alimentar para uma conta ou servidor nesta versão. Quando o usuário escolhe exportar, copiar, compartilhar ou restaurar um arquivo, os dados passam a ser tratados pelo aplicativo ou destino escolhido pelo próprio usuário.',
  '6. Retenção e exclusão',
  'Os registros permanecem no aparelho até que o usuário os remova, limpe os dados do aplicativo ou desinstale o app, observadas as rotinas de backup do sistema operacional. A exportação cria uma cópia fora do controle do Movix; o usuário deve apagá-la separadamente quando não precisar mais dela.',
  '7. Segurança e contato',
  'O aplicativo utiliza o armazenamento privado do sistema, mas os registros SharedPreferences não são criptografados individualmente nesta versão. A cópia automática Android está desativada e o usuário pode exportar manualmente seus dados. O app não oferece nesta etapa sincronização ou gestão de conta. Nenhum aplicativo pode garantir segurança absoluta. O responsável deverá preencher nome e canal de contato para solicitações de privacidade antes da publicação.',
];

const List<String> _saude = [
  '1. Não é serviço médico',
  'O Movix não diagnostica, trata, previne ou monitora doenças e não substitui avaliação médica, prescrição, acompanhamento nutricional ou orientação individual de profissional de educação física.',
  '2. Antes de treinar',
  'Considere sua condição de saúde, experiência, limitações, lesões, medicamentos e orientações recebidas de profissionais. Se tiver dúvidas sobre sua aptidão para exercício, procure avaliação profissional antes de iniciar ou alterar um programa.',
  '3. Durante o exercício',
  'Utilize técnica e cargas compatíveis com sua capacidade, confira a segurança dos equipamentos e, quando necessário, peça supervisão. Interrompa o exercício diante de dor, tontura, falta de ar incomum, palpitação ou mal-estar. Em situação urgente, procure atendimento de emergência.',
  '4. Nutrição e estimativas',
  'Valores nutricionais, calorias, gasto energético, composição corporal e estimativas podem conter imprecisões e dependem dos dados informados. Não use esses números isoladamente para tomar decisões clínicas ou fazer dietas restritivas.',
  '5. Responsabilidade pelo uso',
  'O usuário deve confirmar a adequação dos exercícios, alimentos, metas e informações às suas necessidades. Crianças e adolescentes devem utilizar orientações adequadas à idade e supervisão responsável.',
];
