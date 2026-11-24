import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'telas.dart';

double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

/// 100 -> "100", 22.5 -> "22,5", 1.25 -> "1,25"
String _f(double v) {
  var s = v.toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s.replaceAll('.', ',');
}

double _arred(double v, double passo) => (v / passo).round() * passo;

class CalculadorasTela extends StatefulWidget {
  const CalculadorasTela({super.key});
  @override
  State<CalculadorasTela> createState() => _CalcEstado();
}

class _CalcEstado extends State<CalculadorasTela> {
  int _aba = 0;

  // Anilhas
  final _alvoC = TextEditingController();
  double _barra = 20;
  final Set<double> _ativas = {25, 20, 15, 10, 5, 2.5, 1.25};
  static const _todasAnilhas = <double>[25, 20, 15, 10, 5, 2.5, 2, 1.25, 1, 0.5];

  // 1RM
  final _pesoC = TextEditingController();
  final _repsC = TextEditingController();

  // Aquecimento
  final _trabC = TextEditingController();

  @override
  void dispose() {
    _alvoC.dispose();
    _pesoC.dispose();
    _repsC.dispose();
    _trabC.dispose();
    super.dispose();
  }

  Widget _campo(TextEditingController c, String rotulo, String sufixo,
      {bool inteiro = false}) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: !inteiro),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(inteiro ? r'[0-9]' : r'[0-9.,]')),
      ],
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: rotulo,
        suffixText: sufixo,
        filled: true,
        fillColor: branco(.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: branco(.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: branco(.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: kPrimaria, width: 1.6),
        ),
      ),
    );
  }

  Widget _aviso(String t) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(t,
            style: const TextStyle(color: kMudo, fontSize: 12.5, height: 1.35)),
      );

  // ---------------- ANILHAS ----------------
  Color _corAnilha(double p) {
    if (p >= 25) return const Color(0xFFA3203F);
    if (p >= 20) return const Color(0xFF7A1630);
    if (p >= 15) return const Color(0xFFC9546F);
    if (p >= 10) return const Color(0xFFE8DCC8);
    if (p >= 5) return const Color(0xFFC9B79C);
    return const Color(0xFF8D7B68);
  }

  double _alturaAnilha(double p) {
    if (p >= 25) return 112;
    if (p >= 20) return 100;
    if (p >= 15) return 88;
    if (p >= 10) return 76;
    if (p >= 5) return 62;
    if (p >= 2.5) return 50;
    if (p >= 2) return 46;
    if (p >= 1.25) return 40;
    if (p >= 1) return 36;
    return 32;
  }

  Widget _abaAnilhas() {
    final alvo = _num(_alvoC.text);
    Widget resultado = const SizedBox.shrink();
    if (alvo != null && alvo > 0) {
      if (alvo > 1000) {
        resultado = _aviso('Informe uma carga de até 1000 kg.');
      } else if (alvo < _barra) {
        resultado = _aviso('A carga é menor que a barra (${_f(_barra)} kg).');
      } else if (_ativas.isEmpty) {
        resultado = _aviso('Marque ao menos uma anilha disponível.');
      } else {
        final disp = _ativas.toList()..sort((a, b) => b.compareTo(a));
        var resto = (alvo - _barra) / 2;
        final usadas = <double>[];
        for (final p in disp) {
          while (resto + 1e-9 >= p) {
            usadas.add(p);
            resto = double.parse((resto - p).toStringAsFixed(3));
          }
        }
        final porLado = usadas.fold<double>(0, (a, b) => a + b);
        final total = _barra + 2 * porLado;
        final contagem = <double, int>{};
        for (final p in usadas) {
          contagem[p] = (contagem[p] ?? 0) + 1;
        }
        final exato = resto < 1e-6;
        resultado = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Vidro(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cada lado da barra', style: titulo(22)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 124,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: SingleChildScrollView(
                        key: ValueKey(usadas.join(',')),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 34,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF9A9A9F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            for (final p in usadas)
                              Container(
                                width: p >= 5 ? 16 : 11,
                                height: _alturaAnilha(p),
                                margin: const EdgeInsets.only(left: 3),
                                decoration: BoxDecoration(
                                  color: _corAnilha(p),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            Container(
                              width: 60,
                              height: 14,
                              margin: const EdgeInsets.only(left: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9A9A9F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (usadas.isEmpty)
                    const Text('Só a barra, sem anilhas.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in contagem.entries)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: branco(.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _corAnilha(e.key)),
                                ),
                                const SizedBox(width: 8),
                                Text('${e.value} × ${_f(e.key)} kg',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  Text('Total na barra: ${_f(total)} kg',
                      style: titulo(26)),
                  if (!exato)
                    _aviso(
                        'Com as anilhas marcadas não dá para chegar em ${_f(alvo)} kg. '
                        'O mais próximo é ${_f(total)} kg (faltam ${_f(alvo - total)} kg).'),
                ],
              ),
            ),
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campo(_alvoC, 'Carga total desejada', 'kg'),
        const SizedBox(height: 14),
        const Text('Peso da barra', style: TextStyle(color: kMudo)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final b in const [10.0, 15.0, 20.0])
              ChoiceChip(
                label: Text('${_f(b)} kg'),
                selected: _barra == b,
                onSelected: (_) => setState(() => _barra = b),
              ),
          ],
        ),
        const SizedBox(height: 14),
        const Text('Anilhas disponíveis na sua academia',
            style: TextStyle(color: kMudo)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final a in _todasAnilhas)
              FilterChip(
                label: Text(_f(a)),
                selected: _ativas.contains(a),
                onSelected: (v) => setState(() {
                  if (v) {
                    _ativas.add(a);
                  } else {
                    _ativas.remove(a);
                  }
                }),
              ),
          ],
        ),
        resultado,
        _aviso('Considera anilhas iguais nos dois lados. Confira sempre se a barra está bem travada.'),
      ],
    );
  }

  // ---------------- 1RM ----------------
  Widget _abaUmRm() {
    final peso = _num(_pesoC.text);
    final reps = int.tryParse(_repsC.text.trim());
    Widget resultado = const SizedBox.shrink();
    if (peso != null && peso > 0 && reps != null) {
      if (reps < 1 || reps > 30) {
        resultado = _aviso('Informe de 1 a 30 repetições.');
      } else {
        final epley = reps == 1 ? peso : peso * (1 + reps / 30);
        final brzycki = reps == 1 ? peso : peso * 36 / (37 - reps);
        final media = (epley + brzycki) / 2;
        const tabela = <List<num>>[
          [100, 1], [95, 2], [90, 4], [85, 6], [80, 8],
          [75, 10], [70, 12], [65, 15], [60, 20],
        ];
        resultado = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Vidro(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sua carga máxima estimada (1RM)',
                      style: TextStyle(color: kMudo)),
                  const SizedBox(height: 4),
                  Text('≈ ${_f(_arred(media, 0.5))} kg', style: titulo(48)),
                  Text(
                      'Epley: ${_f(_arred(epley, 0.5))} kg  •  Brzycki: ${_f(_arred(brzycki, 0.5))} kg',
                      style: const TextStyle(color: kMudo, fontSize: 13)),
                  if (reps > 12)
                    _aviso('Acima de 12 repetições a estimativa perde precisão. Use séries de 3 a 10 para um resultado melhor.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Cargas por percentual', style: titulo(22)),
            const SizedBox(height: 6),
            for (final l in tabela)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                        width: 56,
                        child: Text('${l[0]}%',
                            style: const TextStyle(color: kBege))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: l[0] / 100,
                          minHeight: 8,
                          backgroundColor: branco(.08),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(kPrimaria),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 108,
                      child: Text(
                          '${_f(_arred(media * l[0] / 100, 0.5))} kg · ~${l[1]}x',
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
            _aviso('É uma estimativa. Não teste a carga máxima real sem alguém para ajudar.'),
          ],
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _campo(_pesoC, 'Carga usada', 'kg')),
            const SizedBox(width: 12),
            Expanded(child: _campo(_repsC, 'Repetições', 'x', inteiro: true)),
          ],
        ),
        const SizedBox(height: 4),
        _aviso('Use a série mais pesada em que você fez as repetições com boa técnica.'),
        resultado,
      ],
    );
  }

  // ---------------- AQUECIMENTO ----------------
  Widget _abaAquecimento() {
    final trab = _num(_trabC.text);
    Widget resultado = const SizedBox.shrink();
    if (trab != null && trab > 0) {
      if (trab > 1000) {
        resultado = _aviso('Informe uma carga de até 1000 kg.');
      } else if (trab <= 20) {
        resultado = _aviso('Com carga leve, uma ou duas séries de 12 com carga bem menor já aquecem.');
      } else {
        const esquema = <List<num>>[[40, 10], [60, 6], [75, 4], [90, 2]];
        final linhas = <List<num>>[];
        double? anterior;
        for (final e in esquema) {
          final c = _arred(trab * e[0] / 100, 2.5);
          if (c < 1 || c >= trab || c == anterior) continue;
          linhas.add([c, e[1]]);
          anterior = c;
        }
        resultado = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Vidro(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Séries de aquecimento', style: titulo(22)),
                  const SizedBox(height: 8),
                  for (var i = 0; i < linhas.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: branco(.1)),
                            child: Text('${i + 1}',
                                style: const TextStyle(color: kBege)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('${_f(linhas[i][0].toDouble())} kg',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                          ),
                          Text('${linhas[i][1]} repetições',
                              style: const TextStyle(color: kMudo)),
                        ],
                      ),
                    ),
                  const Divider(height: 22),
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: kPrimaria),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Depois: séries de trabalho com ${_f(trab)} kg',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _aviso('Descanse de 30 a 60 segundos entre as séries de aquecimento. Pare antes de sentir cansaço.'),
          ],
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campo(_trabC, 'Carga da série de trabalho', 'kg'),
        resultado,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final abas = ['Anilhas', '1RM', 'Aquecimento'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadoras', style: titulo(28)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          children: [
            Row(
              children: [
                for (var i = 0; i < abas.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(abas[i]),
                      selected: _aba == i,
                      onSelected: (_) => setState(() => _aba = i),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(_aba),
                child: _aba == 0
                    ? _abaAnilhas()
                    : (_aba == 1 ? _abaUmRm() : _abaAquecimento()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
