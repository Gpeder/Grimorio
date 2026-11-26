import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/model/campaign.dart' as dados;
import 'package:pixelarticons/pixel.dart';

enum AcaoEntrada { concluir, apagar }

class LinhaEntrada extends StatelessWidget {
  const LinhaEntrada({
    super.key,
    required this.entrada,
    required this.atual,
    this.onAlternarRevelada,
    this.onAcao,
  });

  final dados.EntradaMissao entrada;

  // É o objetivo atual da missão.
  final bool atual;

  // Só o mestre recebe estes callbacks.
  final VoidCallback? onAlternarRevelada;
  final ValueChanged<AcaoEntrada>? onAcao;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final e = entrada;
    final mestre = onAcao != null;
    final rotulo = atual
        ? 'SESSÃO ${e.sessao} · OBJETIVO ATUAL'
        : 'SESSÃO ${e.sessao}';
    final (icone, corIcone) = atual
        ? (Pixel.target, AppColors.alerta)
        : e.concluida
        ? (Pixel.check, AppColors.sucesso)
        : (Pixel.notes, AppColors.secondary);

    final conteudo = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icone, size: 18, color: corIcone),
        ),
        const SizedBox(width: AppSpacing.small + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      rotulo,
                      style: textTheme.labelSmall?.copyWith(
                        color: atual ? AppColors.alerta : AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (mestre && !e.revelada) ...[
                    const SizedBox(width: 6),
                    const Etiqueta(
                      'Oculta',
                      pequena: true,
                      cor: AppColors.secondary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                e.texto,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface.withValues(
                    alpha: e.concluida ? 0.7 : 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (mestre) ...[
          _BotaoIcone(
            icone: e.revelada ? Pixel.eye : Pixel.eyeoff,
            tooltip: e.revelada ? 'Esconder dos heróis' : 'Revelar aos heróis',
            onTap: onAlternarRevelada,
          ),
          PopupMenuButton<AcaoEntrada>(
            tooltip: 'Mais opções',
            icon: Icon(
              Pixel.morevertical,
              size: 18,
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
            onSelected: onAcao,
            itemBuilder: (_) => [
              if (!e.concluida)
                const PopupMenuItem(
                  value: AcaoEntrada.concluir,
                  child: Text('Marcar como concluída'),
                ),
              const PopupMenuItem(
                value: AcaoEntrada.apagar,
                child: Text('Apagar'),
              ),
            ],
          ),
        ],
      ],
    );

    final caixa = atual
        ? Container(
            padding: const EdgeInsets.all(AppSpacing.small + 4),
            decoration: BoxDecoration(
              color: AppColors.alerta.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              border: Border.all(color: AppColors.alerta, width: 1.5),
            ),
            child: conteudo,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
            child: conteudo,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small + 4),
      child: Opacity(opacity: mestre && !e.revelada ? 0.45 : 1, child: caixa),
    );
  }
}

class _BotaoIcone extends StatelessWidget {
  const _BotaoIcone({required this.icone, required this.tooltip, this.onTap});

  final IconData icone;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.small),
          child: Icon(icone, size: 18, color: AppColors.secondary),
        ),
      ),
    );
  }
}
