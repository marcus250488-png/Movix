import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'extras.dart';
import 'evolucao.dart';
import 'state.dart';
import 'telas.dart';
import 'transicao.dart';
import 'nutricao.dart';
import 'passos.dart';
import 'onboarding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovixBootstrap());
}

/// Exibe a identidade imediatamente; a leitura local acontece depois do primeiro frame.
class MovixBootstrap extends StatefulWidget {
  const MovixBootstrap({super.key});
  @override
  State<MovixBootstrap> createState() => _MovixBootstrapState();
}

class _MovixBootstrapState extends State<MovixBootstrap> {
  bool _pronto = false;
  Object? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      await app.init();
      await app.aplicarManterTela();
      if (mounted) setState(() { _pronto = true; _erro = null; });
    } catch (e) {
      if (mounted) setState(() => _erro = e);
    }
  }

  @override
  Widget build(BuildContext context) => _pronto
      ? const TreinoApp()
      : MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF120609)),
          home: Scaffold(
            backgroundColor: const Color(0xFF120609),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/marca/logo.png', width: 112, height: 112),
                  const SizedBox(height: 22),
                  const Text('MOVIX', style: TextStyle(fontFamily: 'sans-serif-condensed', fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 4, color: Color(0xFFE8DCC8))),
                  const SizedBox(height: 22),
                  if (_erro == null) const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA3203F))),
                  if (_erro != null) ...[
                    const Padding(padding: EdgeInsets.all(16), child: Text('Não foi possível carregar seus dados.', textAlign: TextAlign.center)),
                    TextButton(onPressed: _inicializar, child: const Text('Tentar novamente')),
                  ],
                ],
              ),
            ),
          ),
        );
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        pageTransitionsTheme: kTransicoes,
        chipTheme: ChipThemeData(
          side: BorderSide(color: branco(.14)),
          backgroundColor: branco(.07),
          selectedColor: kPrimaria.withOpacity(0.30),
          checkmarkColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(primary: kPrimaria, surface: kSuperf),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      builder: (context, child) => Fundo(child: child ?? const SizedBox()),
      // O Movix funciona localmente e não exige conta para abrir.
      // Login/sincronização serão reintroduzidos somente na fase de nuvem.
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellEstado();
}

class _ShellEstado extends State<Shell> {
  int i = 0;
  bool _compacto = false;

  @override
  void initState() {
    super.initState();
    app.xpAviso.addListener(_aoXp);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Treino em andamento? Volta direto para ele.
      if (await retomarTreinoSalvo(context)) return;
      if (!mounted) return;
      await mostrarOnboardingSeNecessario(context);
      if (!mounted) return;
      await pedirPermissoesInicial(context);
    });
  }

  @override
  void dispose() {
    app.xpAviso.removeListener(_aoXp);
    super.dispose();
  }

  /// Aviso rápido quando o app dá XP (e quando sobe de nível).
  void _aoXp() {
    final a = app.xpAviso.value;
    if (a == null || !mounted) return;
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      backgroundColor: kSuperf,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: branco(.14)),
      ),
      content: Row(
        children: [
          const Icon(Icons.bolt, color: kPrimaria),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.texto,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                if (a.extra != null)
                  Text(a.extra!,
                      style: const TextStyle(color: kMudo, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  void _ir(int n) => setState(() => i = n);

  bool _aoRolar(ScrollNotification n) {
    if (n is UserScrollNotification) {
      final reduzir = n.direction == ScrollDirection.reverse;
      if (reduzir != _compacto) setState(() => _compacto = reduzir);
    }
    return false;
  }

  Widget _btn(int n, IconData icone, String rotulo) {
    final sel = i == n;
    return Semantics(
      label: rotulo,
      button: true,
      child: GestureDetector(
        onTap: () => _ir(n),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _compacto ? 44 : 54,
          height: _compacto ? 40 : 48,
          decoration: BoxDecoration(
            color: sel ? branco(.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: sel
                ? [BoxShadow(color: kPrimaria.withOpacity(.30), blurRadius: 16, spreadRadius: 1)]
                : const [],
          ),
          child: Icon(icone, color: sel ? Colors.white : kMudo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _aoRolar,
            child: IndexedStack(
              index: i,
              children: [
                InicioTela(irPara: _ir),
                const EvolucaoTela(),
                const BibliotecaTela(),
                const NutricaoTela(),
                MaisTela(irPara: _ir),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: SafeArea(
              child: Center(
                child: Vidro(
                  padding: EdgeInsets.all(_compacto ? 5 : 8),
                  raio: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _btn(0, Icons.home_rounded, 'Início'),
                      _btn(1, Icons.show_chart, 'Evolução'),
                      _btn(2, Icons.fitness_center, 'Biblioteca'),
                      _btn(3, Icons.restaurant_menu, 'Nutrição'),
                      _btn(4, Icons.more_horiz, 'Mais'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
