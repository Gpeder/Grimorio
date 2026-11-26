import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/progress_bar.dart';

class PersonagemCard extends StatelessWidget {
  const PersonagemCard({
    super.key,
    required this.personagem,
    this.nomeCampanha,
    this.onTap,
  });

  final Personagem personagem;
  final String? nomeCampanha;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final classes = personagem.classes.map((c) => c.nome).join(' / ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: _conteudo(textTheme, classes),
    );
  }

  Widget _conteudo(TextTheme textTheme, String classes) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ImageFrame(
                imagePath: personagem.retrato,
                selected: personagem.ativo,
              ),
              if (personagem.ativo)
                const Positioned(top: 6, right: 6, child: _AtivaBadge()),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            personagem.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$classes · Nv ${personagem.nivel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.alerta),
          ),
          const SizedBox(height: 6),
          ProgressBar(
            value: personagem.hpAtual,
            max: personagem.hpMax,
            color: AppColors.vida,
            height: 8,
            showText: false,
          ),
          const SizedBox(height: 6),
          Text(
            nomeCampanha ?? 'Sem campanha',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtivaBadge extends StatelessWidget {
  const _AtivaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.sucesso.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: AppColors.sucesso),
      ),
      child: Text(
        'ATIVA',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.alerta,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
