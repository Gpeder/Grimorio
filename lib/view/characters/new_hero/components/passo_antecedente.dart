import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:pixelarticons/pixel.dart';

class PassoAntecedente extends StatelessWidget {
  const PassoAntecedente({
    super.key,
    required this.antecedente,
    required this.onAntecedente,
    required this.onCriar,
  });

  final OpcaoAntecedente? antecedente;
  final ValueChanged<OpcaoAntecedente> onAntecedente;
  final VoidCallback onCriar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.small,
        children: [
          Text(
            'O que seu herói fazia antes da aventura.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          for (final a in antecedentesMock)
            CaixaOpcao(
              selecionado: a.key == antecedente?.key,
              onTap: () => onAntecedente(a),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.nome,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Etiqueta(a.srd ? 'SRD' : 'Personalizado', pequena: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.descricao,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final p in a.pericias) Etiqueta(p),
                      if (a.idiomasExtras > 0)
                        Etiqueta('+${a.idiomasExtras} idiomas'),
                      for (final e in a.extras) Etiqueta(e),
                    ],
                  ),
                ],
              ),
            ),
          _TracejadoButton(texto: 'Criar antecedente', onTap: onCriar),
        ],
      ),
    );
  }
}

class _TracejadoButton extends StatelessWidget {
  const _TracejadoButton({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(AppSpacing.radius);

    return InkWell(
      onTap: onTap,
      borderRadius: raio,
      child: CustomPaint(
        painter: _BordaTracejada(
          cor: AppColors.alerta.withValues(alpha: 0.6),
          raio: AppSpacing.radius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Pixel.plus, size: 16, color: AppColors.alerta),
              const SizedBox(width: AppSpacing.small),
              Text(
                texto,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.alerta,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  const _BordaTracejada({required this.cor, required this.raio});

  final Color cor;
  final double raio;

  static const _traco = 5.0;
  static const _vao = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final contorno = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(raio),
        ).deflate(0.6),
      );
    for (final metrica in contorno.computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += _traco + _vao) {
        canvas.drawPath(metrica.extractPath(d, d + _traco), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejada old) => old.cor != cor || old.raio != raio;
}
