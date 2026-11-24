import 'dart:math' as math;
import 'package:flutter/material.dart';

class MovixSplash extends StatefulWidget {
  const MovixSplash({super.key, this.erro, this.onTentarNovamente});
  final String? erro;
  final VoidCallback? onTentarNovamente;
  @override
  State<MovixSplash> createState() => MovixSplashState();
}

class MovixSplashState extends State<MovixSplash>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 2600),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) _pulse.repeat(reverse: true);
    });
  late final AnimationController _pulse = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1300),
  );
  late final AnimationController _exit = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 550),
  );

  @override
  void initState() { super.initState(); _intro.forward(); }
  Future<void> fechar() => _exit.forward();
  @override
  void dispose() { _intro.dispose(); _pulse.dispose(); _exit.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF190A10),
    body: AnimatedBuilder(
      animation: Listenable.merge([_intro, _pulse, _exit]),
      builder: (context, _) => Opacity(
        opacity: 1 - Curves.easeIn.transform(_exit.value),
        child: Transform.scale(
          scale: 1 - .10 * _exit.value,
          child: CustomPaint(
            painter: _MovixSplashPainter(_intro.value, _pulse.value),
            child: SizedBox.expand(
              child: widget.erro == null ? const SizedBox.shrink() : Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEFE4D3), size: 32),
                    const SizedBox(height: 12),
                    const Text('Não foi possível iniciar o Movix', textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFEFE4D3), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.erro!, textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFBDAEAA), fontSize: 12)),
                    if (widget.onTentarNovamente != null) ...[
                      const SizedBox(height: 18),
                      FilledButton(onPressed: widget.onTentarNovamente, child: const Text('Tentar novamente')),
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _MovixSplashPainter extends CustomPainter {
  _MovixSplashPainter(this.t, this.pulse);
  final double t, pulse;
  static const cream = Color(0xFFEFE4D3);
  static const pink = Color(0xFFD6244F);
  double part(double a, double b) => Curves.easeInOut.transform(((t-a)/(b-a)).clamp(0.0, 1.0).toDouble());

  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(r, Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF401423), Color(0xFF250D16), Color(0xFF190A10)],
      stops: [0, .52, 1],
    ).createShader(r));
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    glow.color = pink.withValues(alpha: .18);
    c.drawCircle(Offset(s.width*.18, s.height*.15), s.shortestSide*.22, glow);
    glow.color = const Color(0xFF7A2036).withValues(alpha: .20);
    c.drawCircle(Offset(s.width*.88, s.height*.82), s.shortestSide*.28, glow);

    final center = Offset(s.width/2, s.height*.43);
    final scale = math.min(s.width*.60, 300.0).toDouble()/480;
    c.save(); c.translate(center.dx-240*scale, center.dy-240*scale); c.scale(scale);
    final path = Path()..moveTo(130,332)..lineTo(130,152)..lineTo(240,274)..lineTo(350,152)..lineTo(350,332);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length*part(.05,.43));
    c.drawPath(drawn, Paint()..style=PaintingStyle.stroke..strokeWidth=46..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round..color=cream);
    if (t > .70) {
      final shine = part(.73,1.0);
      final start = metric.length*(shine*.78);
      c.drawPath(metric.extractPath(start, math.min(metric.length,start+metric.length*.20).toDouble()),
        Paint()..style=PaintingStyle.stroke..strokeWidth=46..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round
          ..color=Colors.white.withValues(alpha:.55*(1-shine*.35))..maskFilter=const MaskFilter.blur(BlurStyle.normal,8));
    }
    final fallRaw = ((t-.40)/(.72-.40)).clamp(0.0,1.0).toDouble();
    double dropY;
    double dropScaleX = 1, dropScaleY = 1;
    if (fallRaw < .52) {
      dropY = -250 * (1 - fallRaw/.52);
    } else if (fallRaw < .74) {
      final bounce = (fallRaw-.52)/.22;
      dropY = -14 * math.sin(bounce*math.pi);
      dropScaleX = 1 + .16*math.sin(bounce*math.pi);
      dropScaleY = 1 - .20*math.sin(bounce*math.pi);
    } else {
      dropY = 0;
    }
    final drop = part(.40,.72);
    final dot = Offset(240,112+dropY);
    final ring = part(.55,.88);
    if (ring > 0 && ring < 1) {
      for (var i=0;i<2;i++) {
        final q=(ring+i*.12).clamp(0.0,1.0);
        c.drawCircle(dot,24+q*58,Paint()..style=PaintingStyle.stroke..strokeWidth=(i==0?5.0:3.0)..color=pink.withValues(alpha:.75*(1-q)));
      }
    }
    final breathe = t>=1 ? .04*pulse : .025*math.sin(t*math.pi*4);
    c.save();
    c.translate(dot.dx,dot.dy);
    c.scale(dropScaleX*(1+breathe),dropScaleY*(1+breathe));
    c.drawCircle(Offset.zero,24,Paint()..color=pink.withValues(alpha:drop)..maskFilter=const MaskFilter.blur(BlurStyle.normal,1.5));
    c.drawCircle(Offset.zero,27,Paint()..color=pink.withValues(alpha:.35*drop)..maskFilter=const MaskFilter.blur(BlurStyle.normal,18));
    c.restore();
    c.restore();

    final reveal=part(.78,.98);
    final tp=TextPainter(
      text:TextSpan(text:'SUA EVOLUÇÃO COMEÇA AQUI',style:TextStyle(
        color:cream.withValues(alpha:.55*reveal),fontSize:10.5,fontWeight:FontWeight.w600,letterSpacing:3.1)),
      textDirection:TextDirection.ltr,textAlign:TextAlign.center,
    )..layout(maxWidth:s.width-24);
    tp.paint(c,Offset((s.width-tp.width)/2,center.dy+240*scale+24));
    final y=center.dy+240*scale+62;
    final bar=RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(s.width/2,y),width:132,height:3),const Radius.circular(99));
    c.drawRRect(bar,Paint()..color=cream.withValues(alpha:.10*reveal));
    if(reveal>0){
      final x=s.width/2-66+(((t*1.6+pulse*.4)%1.8)-.45)*132;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x,y-1.5,60,3),const Radius.circular(99)),
        Paint()..shader=const LinearGradient(colors:[Colors.transparent,pink,Colors.transparent]).createShader(Rect.fromLTWH(x,y-2,60,4)));
    }

    // Pequena prévia dos três pilares do Movix. Eles entram depois da marca,
    // reforçando a proposta sem transformar a splash em um vídeo pesado.
    final cardsReveal = part(.78, .98);
    final labels = const ['TREINO', 'EVOLUÇÃO', 'NUTRIÇÃO'];
    final subtitles = const ['rotina', 'progresso', 'hábitos'];
    final cardW = math.min(106.0, (s.width - 56) / 3);
    const gap = 7.0;
    final totalW = cardW * 3 + gap * 2;
    final left = (s.width - totalW) / 2;
    final cardY = s.height * .72;
    for (var i = 0; i < 3; i++) {
      final delay = (cardsReveal - i * .12).clamp(0.0, 1.0).toDouble();
      final x = left + i * (cardW + gap);
      final offsetY = (1 - Curves.easeOut.transform(delay)) * 12;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, cardY + offsetY, cardW, 48),
        const Radius.circular(12),
      );
      c.drawRRect(rect, Paint()..color = cream.withValues(alpha: .055 * delay));
      c.drawRRect(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = 1
        ..color = cream.withValues(alpha: .13 * delay));
      final title = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(
          color: cream.withValues(alpha: .78 * delay), fontSize: 8.5,
          fontWeight: FontWeight.w700, letterSpacing: 1.0,
        )),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: cardW - 12);
      title.paint(c, Offset(x + 6, cardY + 11 + offsetY));
      final subtitle = TextPainter(
        text: TextSpan(text: subtitles[i], style: TextStyle(
          color: cream.withValues(alpha: .42 * delay), fontSize: 8,
        )),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: cardW - 12);
      subtitle.paint(c, Offset(x + 6, cardY + 27 + offsetY));
    }
  }
  @override
  bool shouldRepaint(covariant _MovixSplashPainter old) => old.t!=t || old.pulse!=pulse;
}
