import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/widgets/etiqueta.dart';

class SessoesTab extends StatelessWidget {
  const SessoesTab({super.key, required this.sessoes, this.mostrarXp = true});

  final List<Sessao> sessoes;
  final bool mostrarXp;

  @override
  Widget build(BuildContext context) {
    if (sessoes.isEmpty) {
      return Text(
        'Nenhuma sessão encerrada ainda.',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.55)),
      );
    }
    final ordenadas = [...sessoes]..sort((a, b) => b.numero - a.numero);

    return Column(
      children: [
        for (var i = 0; i < ordenadas.length; i++)
          _ItemLinhaTempo(
            sessao: ordenadas[i],
            ultima: i == ordenadas.length - 1,
            mostrarXp: mostrarXp,
          ),
      ],
    );
  }
}

class _ItemLinhaTempo extends StatelessWidget {
  const _ItemLinhaTempo({
    required this.sessao,
    required this.ultima,
    required this.mostrarXp,
  });

  final Sessao sessao;
  final bool ultima;
  final bool mostrarXp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final s = sessao;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    color: AppColors.alerta,
                  ),
                ),
                if (!ultima)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.only(top: 6),
                      color: AppColors.secondary.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.small + 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SESSÃO ${s.numero} · ${formatarDia(s.data)}',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.alerta,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (mostrarXp && s.xpTotal > 0)
                        Etiqueta(
                          '+${formatarMilhar(s.xpTotal)} XP',
                          pequena: true,
                          cor: AppColors.exp,
                        ),
                    ],
                  ),
                  if (s.resumo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      s.resumo,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
