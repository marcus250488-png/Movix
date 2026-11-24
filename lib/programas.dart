import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'state.dart';
import 'telas.dart';

/// Programas de treino prontos (assets/programas.json).
/// Programas marcados como premium exigem acesso Movix Pro.
class ProgramaItem {
  final String exId;
  final int series;
  final String reps;
  ProgramaItem(this.exId, this.series, this.reps);
}

class ProgramaDia {
  final String nome, foco;
  final int weekday;
  final List<ProgramaItem> itens;
  ProgramaDia(this.nome, this.weekday, this.foco, this.itens);
}

class Programa {
  final String id, nome, nivel, objetivo, equipamento, descricao;
  final int diasSemana;
  final bool premium;
  final List<String> objetivos;
  final String local; // 'academia' ou 'casa'
  final List<ProgramaDia> dias;
  Programa({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.objetivo,
    required this.equipamento,
    required this.descricao,
    required this.diasSemana,
    required this.premium,
    required this.objetivos,
    required this.local,
    required this.dias,
  });

  factory Programa.fromJson(Map<String, dynamic> j) => Programa(
        id: j['id'] as String,
        nome: j['nome'] as String,
        nivel: j['nivel'] as String,
        objetivo: (j['objetivo'] ?? '') as String,
        equipamento: (j['equipamento'] ?? '') as String,
        descricao: (j['descricao'] ?? '') as String,
        diasSemana: j['diasSemana'] as int,
        premium: (j['premium'] ?? false) as bool,
        objetivos: List<String>.from(j['objetivos'] ?? const []),
        local: (j['local'] ?? 'academia') as String,
        dias: (j['dias'] as List).map((d) {
          final m = Map<String, dynamic>.from(d as Map);
          return ProgramaDia(
            m['nome'] as String,
            m['weekday'] as int,
            (m['foco'] ?? '') as String,
            (m['itens'] as List).map((i) {
              final x = Map<String, dynamic>.from(i as Map);
              return ProgramaItem(
                  x['exId'] as String, x['series'] as int, x['reps'] as String);
            }).toList(),
          );
        }).toList(),
      );

  /// Cria dias novos (mutáveis) para o plano do app.
  List<Dia> comoPlano() {
    return dias.map((d) {
      final itens = <Item>[];
      for (final i in d.itens) {
        final e = app.ex(i.exId);
        if (e == null) continue; // exercício que não existe mais na biblioteca
        itens.add(Item(
            exId: e.id,
            nome: e.nome,
            grupo: e.grupo,
            series: i.series,
            reps: i.reps));
      }
      return Dia(nome: d.nome, weekday: d.weekday, foco: d.foco, itens: itens);
    }).toList();
  }
}

int nivelIndice(String n) => n == 'Avançado' ? 2 : (n == 'Intermediário' ? 1 : 0);

/// Ordena os programas do mais ao menos indicado para as respostas do onboarding.
/// [nivel]: 0 iniciante, 1 intermediário, 2 avançado. [local]: 'academia' ou 'casa'.
List<Programa> recomendar(List<Programa> todos,
    {required String objetivo,
    required int nivel,
    required int dias,
    required String local}) {
  int pontos(Programa p) {
    var s = 0;
    final d = nivelIndice(p.nivel) - nivel;
    s += d == 0 ? 4 : (d == -1 ? 1 : (d == -2 || d == 1 ? 0 : -4));
    final dd = (p.diasSemana - dias).abs();
    s += dd == 0 ? 4 : (dd == 1 ? 1 : -2);
    if (p.objetivos.contains(objetivo)) s += 3;
    if (local == 'casa') {
      s += p.local == 'casa' ? 6 : -10;
    } else if (p.local == 'casa') {
      s -= 10;
    }
    return s;
  }

  final idx = {for (var i = 0; i < todos.length; i++) todos[i].id: i};
  final lista = [...todos];
  lista.sort((a, b) {
    final c = pontos(b).compareTo(pontos(a));
    return c != 0 ? c : idx[a.id]!.compareTo(idx[b.id]!);
  });
  return lista;
}

Future<List<Programa>> carregarProgramas() async {
  final txt = await rootBundle.loadString('assets/programas.json');
  final m = jsonDecode(txt) as Map<String, dynamic>;
  return (m['programas'] as List)
      .map((e) => Programa.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

void abrirProgramas(BuildContext context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ProgramasTela()));
}

const _diasCurtos = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

class ProgramasTela extends StatefulWidget {
  const ProgramasTela({super.key});
  @override
  State<ProgramasTela> createState() => _ProgramasEstado();
}

class _ProgramasEstado extends State<ProgramasTela> {
  late final Future<List<Programa>> _f = carregarProgramas();
  String _nivel = 'Todos';

  Widget _chip(String t) {
    final sel = _nivel == t;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(t),
        selected: sel,
        onSelected: (_) => setState(() => _nivel = t),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Programas prontos', style: titulo(28)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Programa>>(
        future: _f,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(
                child: Text('Não foi possível carregar os programas.',
                    style: TextStyle(color: kMudo)));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snap.data!;
          final lista =
              todos.where((p) => _nivel == 'Todos' || p.nivel == _nivel).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _chip('Todos'),
                  _chip('Iniciante'),
                  _chip('Intermediário'),
                  _chip('Avançado'),
                ]),
              ),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                      child: Text('Nenhum programa neste nível ainda.',
                          style: TextStyle(color: kMudo))),
                ),
              for (final p in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Vidro(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => p.premium
                                ? MovixProTela(programa: p)
                                : ProgramaDetalheTela(programa: p))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(p.nome, style: titulo(28))),
                            if (p.premium)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.lock, color: kBege, size: 18),
                              ),
                            const Icon(Icons.chevron_right, color: kMudo),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(p.objetivo,
                            style: const TextStyle(color: kMudo)),
                        Wrap(children: [
                          if (p.premium) _tag('MOVIX PRO'),
                          _tag(p.nivel),
                          _tag('${p.diasSemana} dias por semana'),
                          _tag(p.equipamento),
                        ]),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Apresentação do plano Pro. A compra só será habilitada quando os produtos
/// forem cadastrados e configurados no Google Play Console.
class MovixProTela extends StatelessWidget {
  final Programa? programa;
  const MovixProTela({super.key, this.programa});

  Widget _beneficio(IconData icon, String titulo, String descricao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBege, size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(descricao, style: const TextStyle(color: kMudo, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conheça o Movix Pro', style: titulo(27)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
        children: [
          Vidro(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.workspace_premium, color: kBege, size: 42),
                const SizedBox(height: 12),
                Text('Evolua com o Movix Pro', style: titulo(34)),
                const SizedBox(height: 8),
                const Text(
                  'Tenha acesso a programas exclusivos e, conforme forem liberados, ferramentas avançadas para acompanhar seu desempenho.',
                  style: TextStyle(color: kMudo, height: 1.4),
                ),
                if (programa != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: kPrimaria.withOpacity(.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kPrimaria.withOpacity(.45)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: kBege),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '"${programa!.nome}" é um programa exclusivo do Pro.',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Vidro(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O que está incluído', style: titulo(25)),
                _beneficio(Icons.fitness_center, 'Programas exclusivos',
                    'Planos de treino identificados como Movix Pro.'),
                _beneficio(Icons.insights, 'Análises avançadas',
                    'Recursos avançados de desempenho previstos para a versão Pro.'),
                _beneficio(Icons.query_stats, 'Relatórios avançados',
                    'Acompanhamento ampliado da sua evolução, conforme os recursos forem disponibilizados.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Vidro(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Planos', style: titulo(25)),
                const SizedBox(height: 8),
                const Text('Mensal', style: TextStyle(fontWeight: FontWeight.w700)),
                const Text('Preço informado pela Google Play quando a assinatura for ativada.',
                    style: TextStyle(color: kMudo, height: 1.35)),
                const Divider(height: 24, color: Colors.white24),
                const Text('Anual', style: TextStyle(fontWeight: FontWeight.w700)),
                const Text('Preço informado pela Google Play quando a assinatura for ativada.',
                    style: TextStyle(color: kMudo, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: branco(.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: branco(.12)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: kBege),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'As assinaturas ainda não estão disponíveis nesta versão. Nenhuma cobrança será feita. A compra será ativada após configurar e testar os produtos no Google Play Console.',
                    style: TextStyle(color: kMudo, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgramaDetalheTela extends StatelessWidget {
  final Programa programa;
  const ProgramaDetalheTela({super.key, required this.programa});

  Future<void> _usar(BuildContext context) async {
    if (programa.premium) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => MovixProTela(programa: programa)));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    if (app.plano.isNotEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: kSuperf,
          title: const Text('Trocar o plano atual?'),
          content: const Text(
              'Seu plano semanal atual será substituído por este programa. '
              'Seu histórico de treinos continua salvo.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Usar programa')),
          ],
        ),
      );
      if (ok != true) return;
    }
    await app.salvarPlano(programa.comoPlano());
    nav.popUntil((r) => r.isFirst);
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kSuperf,
      content: Text('Programa "${programa.nome}" aplicado ao seu plano.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (programa.premium) return MovixProTela(programa: programa);
    return Scaffold(
      appBar: AppBar(
        title: Text(programa.nome, style: titulo(26)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Text(programa.descricao,
              style: const TextStyle(color: kMudo, height: 1.35)),
          const SizedBox(height: 6),
          Text(
              '${programa.nivel} • ${programa.diasSemana} dias por semana • ${programa.equipamento}',
              style: const TextStyle(color: kBege, fontSize: 13)),
          const SizedBox(height: 14),
          for (final d in programa.dias)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Vidro(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_diasCurtos[d.weekday]} • ${d.nome}',
                        style: titulo(22)),
                    const SizedBox(height: 8),
                    for (final i in d.itens)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(app.ex(i.exId)?.nome ?? i.exId),
                            ),
                            const SizedBox(width: 8),
                            Text('${i.series} × ${i.reps}',
                                style: const TextStyle(color: kMudo)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          FilledButton(
            style: estiloPrimario,
            onPressed: () => _usar(context),
            child: const Text('Usar este programa'),
          ),
        ],
      ),
    );
  }
}
