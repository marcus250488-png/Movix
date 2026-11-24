import 'dart:async';
import 'package:flutter/material.dart';

/// Apresenta os avisos do Movix no centro da tela, mantendo a identidade visual.
/// Recebe um SnackBar para preservar mensagens e ações já existentes no app.
OverlayEntry? _avisoMovixAtivo;
Timer? _timerAvisoMovix;

void mostrarAvisoMovix(BuildContext context, SnackBar aviso) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  // Um aviso novo substitui o anterior, evitando cartões empilhados.
  _timerAvisoMovix?.cancel();
  final anterior = _avisoMovixAtivo;
  if (anterior != null) {
    if (anterior.mounted) anterior.remove();
    anterior.dispose();
  }

  final entry = OverlayEntry(
    builder: (overlayContext) => _AvisoCentral(aviso: aviso),
  );
  _avisoMovixAtivo = entry;
  overlay.insert(entry);
  final tempo = aviso.duration.inMilliseconds < 1800
      ? const Duration(milliseconds: 1800)
      : aviso.duration;
  _timerAvisoMovix = Timer(tempo, () {
    if (entry.mounted) entry.remove();
    entry.dispose();
    if (identical(_avisoMovixAtivo, entry)) _avisoMovixAtivo = null;
  });
}

class _AvisoCentral extends StatelessWidget {
  final SnackBar aviso;
  const _AvisoCentral({required this.aviso});

  @override
  Widget build(BuildContext context) {
    final conteudo = aviso.content;
    return Positioned.fill(
      child: SafeArea(
        child: IgnorePointer(
          ignoring: aviso.action == null,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: .92, end: 1),
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOutCubic,
              builder: (context, escala, child) => Opacity(
                opacity: ((escala - .92) / .08).clamp(0.0, 1.0),
                child: Transform.scale(scale: escala, child: child),
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A111A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFA3203F).withValues(alpha: .48),
                      width: .8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .38),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: const Color(0xFFA3203F).withValues(alpha: .10),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -5,
                        bottom: -12,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: .075,
                            child: Image.asset(
                              'assets/marca/movix_m_watermark.png',
                              width: 104,
                              height: 104,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            aviso.action == null
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            color: const Color(0xFFD6244F),
                            size: 25,
                          ),
                          const SizedBox(width: 13),
                          Flexible(
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                color: Color(0xFFEFE4D3),
                                fontSize: 14.5,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                              child: conteudo,
                            ),
                          ),
                        ],
                      ),
                      if (aviso.action != null)
                        Positioned(
                          right: 0,
                          bottom: -8,
                          child: TextButton(
                            onPressed: aviso.action!.onPressed,
                            child: Text(
                              aviso.action!.label,
                              style: const TextStyle(color: Color(0xFFD6244F)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
