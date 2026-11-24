import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state.dart';
import 'telas.dart';
import 'programas.dart';

const _kFeito = 'movix_onb_feito';

/// Mostra o onboarding na primeira abertura (só se ainda não há plano nem treinos).
Future<void> mostrarOnboardingSeNecessario(BuildContext context) async {
  final p = await SharedPreferences.getInstance();
  if (p.getBool(_kFeito) ?? false) return;
  if (app.plano.isNotEmpty || app.sessoes.isNotEmpty) {
    await p.setBool(_kFeito, true);
    return;
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const OnboardingTela(),
  ));
}

class _Op {
  final String chave, titulo, sub;
  final IconData icone;
  const _Op(this.chave, this.titulo, this.sub, this.icone);
}

const _objetivos = <_Op>[
  _Op('hipertrofia', 'Ganhar massa muscular', 'Treino de volume para crescer', Icons.fitness_center),
  _Op('forca', 'Ficar mais forte', 'Subir carga nos movimentos básicos', Icons.bolt),
  _Op('emagrecer', 'Emagrecer e definir', 'Gastar energia e manter a massa', Icons.local_fire_department),
  _Op('gluteos', 'Glúteos e pernas', 'Prioridade na parte inferior', Icons.directions_run),
  _Op('saude', 'Saúde e hábito', 'Criar rotina e se sentir bem', Icons.favorite_border),
];

const _niveis = <_Op>[
  _Op('0', 'Estou começando', 'Menos de 6 meses de treino', Icons.flag_outlined),
  _Op('1', 'Já treino há um tempo', 'De 6 meses a 2 anos', Icons.trending_up),
  _Op('2', 'Treino há anos', 'Mais de 2 anos e domino a técnica', Icons.emoji_events_outlined),
];

const _diasOp = <_Op>[
  _Op('2', '2 dias por semana', 'Rotina enxuta', Icons.looks_two_outlined),
  _Op('3', '3 dias por semana', 'Equilíbrio ideal', Icons.looks_3_outlined),
  _Op('4', '4 dias por semana', 'Bom volume', Icons.looks_4_outlined),
  _Op('5', '5 dias por semana', 'Dedicação alta', Icons.looks_5_outlined),
  _Op('6', '6 dias por semana', 'Máximo de frequência', Icons.looks_6_outlined),
];

const _locais = <_Op>[
  _Op('academia', 'Academia', 'Máquinas, barras e halteres', Icons.fitness_center),
  _Op('casa', 'Em casa', 'Halteres e peso do corpo', Icons.home_outlined),
];

class OnboardingTela extends StatefulWidget {
  const OnboardingTela({super.key});
  @override
  State<OnboardingTela> createState() => _OnbEstado();
}

class _OnbEstado extends State<OnboardingTela> {
  // 0 boas-vindas, 1 objetivo, 2 experiência, 3 dias, 4 local, 5 resultado
  int _passo = 0;
  bool _frente = true;
  String? _obj, _local;
  int? _nivel, _dias;
  List<Programa> _todos = [];
  bool _erro = false;

  @override
  void initState() {
    super.initState();
    carregarProgramas().then((v) {
      if (mounted) setState(() => _todos = v);
    }).catchError((_) {
      if (mounted) setState(() => _erro = true);
    });
  }

  Future<void> _concluir() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kFeito, true);
    if (_obj != null) await p.setString('movix_obj', _obj!);
    if (_nivel != null) await p.setInt('movix_nivel', _nivel!);
    if (_dias != null) await p.setInt('movix_dias', _dias!);
    if (_local != null) await p.setString('movix_local', _local!);
  }

  void _ir(int n) => setState(() {
        _frente = n > _passo;
        _passo = n;
      });

  void _escolher(VoidCallback set) {
    setState(set);
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) _ir(_passo + 1);
    });
  }

  Future<void> _pular() async {
    await _concluir();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _usar(Programa p) async {
    final nav = Navigator.of(context);
    final m = ScaffoldMessenger.of(context);
    await app.salvarPlano(p.comoPlano());
    await _concluir();
    nav.pop();
    m.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kSuperf,
      content: Text('Pronto! "${p.nome}" é o seu plano agora.'),
    ));
  }

  // ---------- peças visuais ----------
  Widget _barra() {
    return Row(
      children: List.generate(4, (i) {
        final cheio = _passo >= i + 1;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
            decoration: BoxDecoration(
              color: cheio ? kPrimaria : branco(.14),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _cartao(_Op o, bool sel, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: sel ? kPrimaria.withOpacity(.22) : branco(.07),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: sel ? kPrimaria : branco(.14), width: sel ? 1.6 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? kPrimaria : branco(.08),
                ),
                child: Icon(o.icone, color: sel ? Colors.white : kBege),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.titulo,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(o.sub,
                        style: const TextStyle(color: kMudo, fontSize: 13)),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: sel ? 1 : 0,
                child: const Icon(Icons.check_circle, color: kBege),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pergunta(String t, String sub, List<_Op> ops, String? atual,
      void Function(String) aoEscolher) {
    return ListView(
      padding: const EdgeInsets.only(top: 18, bottom: 24),
      children: [
        Text(t, style: titulo(34)),
        const SizedBox(height: 6),
        Text(sub, style: const TextStyle(color: kMudo)),
        const SizedBox(height: 18),
        for (final o in ops) _cartao(o, atual == o.chave, () => aoEscolher(o.chave)),
      ],
    );
  }

  Widget _boasVindas() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (c, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(scale: v, child: child),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Image.asset('assets/marca/logo.png', width: 128, height: 128),
          ),
        ),
        const SizedBox(height: 26),
        Text('Bem-vindo ao Movix', style: titulo(40), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text(
          'Responda 4 perguntas rápidas e a gente indica o programa de treino ideal para você.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kMudo, height: 1.4),
        ),
        const SizedBox(height: 34),
        FilledButton(
          style: estiloPrimario,
          onPressed: () => _ir(1),
          child: const Text('Começar'),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: _pular,
          child: const Text('Agora não', style: TextStyle(color: kMudo)),
        ),
      ],
    );
  }

  Widget _tag(String t) => Container(
        margin: const EdgeInsets.only(right: 6, top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: branco(.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(t, style: const TextStyle(fontSize: 12, color: kBege)),
      );

  List<String> _motivos(Programa p) {
    final r = <String>[];
    if (p.local == 'casa' && _local == 'casa') {
      r.add('Feito para treinar em casa');
    }
    r.add(p.diasSemana == _dias
        ? 'Tem $_dias dias por semana, como você pediu'
        : 'Tem ${p.diasSemana} dias por semana, o mais próximo de $_dias');
    r.add(nivelIndice(p.nivel) == _nivel
        ? 'Nível ${p.nivel}, igual ao seu'
        : 'Nível ${p.nivel}');
    if (p.objetivos.contains(_obj)) r.add('Combina com o seu objetivo');
    return r;
  }

  Widget _resultado() {
    if (_erro || _todos.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_erro) const CircularProgressIndicator(),
          if (_erro)
            const Text('Não foi possível carregar os programas.',
                style: TextStyle(color: kMudo)),
          const SizedBox(height: 16),
          TextButton(onPressed: _pular, child: const Text('Continuar')),
        ],
      );
    }
    final recs = recomendar(_todos,
        objetivo: _obj ?? 'hipertrofia',
        nivel: _nivel ?? 0,
        dias: _dias ?? 3,
        local: _local ?? 'academia');
    final p = recs.first;
    return ListView(
      padding: const EdgeInsets.only(top: 18, bottom: 24),
      children: [
        Text('Seu programa', style: titulo(34)),
        const SizedBox(height: 4),
        const Text('Montado com base nas suas respostas.',
            style: TextStyle(color: kMudo)),
        const SizedBox(height: 16),
        Vidro(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.nome, style: titulo(32)),
              Wrap(children: [
                _tag(p.nivel),
                _tag('${p.diasSemana} dias por semana'),
                _tag(p.equipamento),
              ]),
              const SizedBox(height: 12),
              Text(p.descricao, style: const TextStyle(color: kMudo, height: 1.35)),
              const SizedBox(height: 12),
              for (final m in _motivos(p))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 18, color: kBege),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton(
          style: estiloPrimario,
          onPressed: () => _usar(p),
          child: const Text('Usar este programa'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          style: estiloContornoFino,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProgramaDetalheTela(programa: p))),
          child: const Text('Ver os treinos'),
        ),
        const SizedBox(height: 18),
        Text('Outras boas opções', style: titulo(22)),
        const SizedBox(height: 8),
        for (final o in recs.skip(1).take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Vidro(
              padding: const EdgeInsets.all(14),
              raio: 20,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProgramaDetalheTela(programa: o))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.nome,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('${o.nivel} • ${o.diasSemana} dias por semana',
                            style: const TextStyle(color: kMudo, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: kMudo),
                ],
              ),
            ),
          ),
        TextButton(
          onPressed: _pular,
          child: const Text('Decidir depois', style: TextStyle(color: kMudo)),
        ),
      ],
    );
  }

  Widget _conteudo() {
    switch (_passo) {
      case 0:
        return _boasVindas();
      case 1:
        return _pergunta('Qual é o seu objetivo?', 'Escolha o que mais importa agora.',
            _objetivos, _obj, (v) => _escolher(() => _obj = v));
      case 2:
        return _pergunta('Qual a sua experiência?', 'Seja sincero, isso evita treino pesado demais.',
            _niveis, _nivel?.toString(), (v) => _escolher(() => _nivel = int.parse(v)));
      case 3:
        return _pergunta('Quantos dias você treina?', 'Pense no que dá para manter toda semana.',
            _diasOp, _dias?.toString(), (v) => _escolher(() => _dias = int.parse(v)));
      case 4:
        return _pergunta('Onde você vai treinar?', 'Assim a gente escolhe os equipamentos certos.',
            _locais, _local, (v) => _escolher(() => _local = v));
      default:
        return _resultado();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meio = _passo >= 1 && _passo <= 4;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_passo > 1) {
          _ir(_passo - 1);
        } else {
          _pular();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      if (_passo > 1)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          onPressed: () => _ir(_passo - 1),
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      if (meio)
                        TextButton(
                          onPressed: _pular,
                          child: const Text('Pular', style: TextStyle(color: kMudo)),
                        ),
                    ],
                  ),
                ),
                if (_passo >= 1) _barra(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, anim) {
                      final entrando = child.key == ValueKey(_passo);
                      final dir = (_frente == entrando) ? 1.0 : -1.0;
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                                  begin: Offset(0.12 * dir, 0), end: Offset.zero)
                              .animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(key: ValueKey(_passo), child: _conteudo()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
