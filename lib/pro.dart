import 'package:flutter/material.dart';

class MovixProTela extends StatelessWidget {
  final String? programaNome;
  const MovixProTela({super.key, this.programaNome});

  Widget _beneficio(IconData icon, String titulo, String descricao) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFFE8DCC8), size: 23),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(descricao, style: const TextStyle(color: Color(0xFFB3A394), height: 1.3)),
      ])),
    ]),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Conheça o Movix Pro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFE8DCC8))),
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
    ),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
      _painel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.workspace_premium, color: Color(0xFFE8DCC8), size: 42),
        const SizedBox(height: 12),
        const Text('Evolua com o Movix Pro', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: Color(0xFFE8DCC8))),
        const SizedBox(height: 8),
        const Text('Tenha acesso a programas exclusivos e ferramentas avançadas para acompanhar seu desempenho.', style: TextStyle(color: Color(0xFFB3A394), height: 1.4)),
        if (programaNome != null) ...[
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFA3203F).withValues(alpha: .16), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFA3203F).withValues(alpha: .45))), child: Row(children: [
            const Icon(Icons.lock, color: Color(0xFFE8DCC8)), const SizedBox(width: 10),
            Expanded(child: Text('"$programaNome" é um programa exclusivo do Pro.', style: const TextStyle(fontWeight: FontWeight.w600))),
          ])),
        ],
      ])),
      const SizedBox(height: 16),
      _painel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('O que está incluído', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFE8DCC8))),
        _beneficio(Icons.fitness_center, 'Programas exclusivos', 'Planos de treino identificados como Movix Pro.'),
        _beneficio(Icons.insights, 'Análises avançadas', 'Leitura ampliada do histórico e da evolução.'),
        _beneficio(Icons.query_stats, 'Relatórios avançados', 'Comparações por período, volume e consistência de treino.'),
      ])),
      const SizedBox(height: 14),
      _painel(const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, color: Color(0xFFE8DCC8)), SizedBox(width: 10),
        Expanded(child: Text('Os recursos Pro estão em fase de preparação. Nesta versão não há contratação nem cobrança. O acesso pago será implementado e testado em uma etapa futura.', style: TextStyle(color: Color(0xFFB3A394), height: 1.4))),
      ])),
    ]),
  );

  Widget _painel(Widget child) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF241116), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .10))),
    child: child,
  );
}
