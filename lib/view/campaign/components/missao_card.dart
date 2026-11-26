import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/gerenciador_visibilidade.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:pixelarticons/pixel.dart';

class MissaoCard extends StatelessWidget {
  const MissaoCard({
    super.key,
    required this.missao,
    required this.papel,
    required this.sessaoAtual,
    required this.onTap,
  });

  final Missao missao;
  final PapelCampanha papel;
  final int sessaoAtual;
  final VoidCallback onTap;

  static const _raio = BorderRadius.all(Radius.circular(AppSpacing.radius));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = missao;
    final entradas = const GerenciadorVisibilidade().entradas(m, papel);
    final objetivo = const GerenciadorVisibilidade().objetivoAtual(m, papel);
    final novaEntrada =
        m.ativa && entradas.isNotEmpty && entradas.first.sessao == sessaoAtual;
    final mestre = papel == PapelCampanha.mestre;
    final topo = [
      m.tipo.label.toUpperCase(),
      if (m.regiao.isNotEmpty) m.regiao,
    ].join(' · ');

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: _raio,
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: m.estado.cor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium - 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              topo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.alerta,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (mestre && !m.revelada)
                            const Etiqueta(
                              'Oculta',
                              pequena: true,
                              cor: AppColors.secondary,
                            ),
                          if (novaEntrada) ...[
                            const SizedBox(width: 4),
                            const Etiqueta(
                              'Nova entrada',
                              pequena: true,
                              cor: AppColors.sucesso,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.titulo,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (objetivo != null && m.ativa) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Pixel.target,
                                size: 14,
                                color: AppColors.alerta,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                objetivo.texto,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
