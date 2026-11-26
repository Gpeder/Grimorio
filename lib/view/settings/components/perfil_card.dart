import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/avatar_circle.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:pixelarticons/pixel.dart';

class PerfilCard extends StatelessWidget {
  const PerfilCard({
    super.key,
    required this.usuario,
    required this.herois,
    required this.campanhas,
    this.sessoes,
    required this.onEditar,
    required this.onEntrar,
  });

  final Usuario usuario;
  final int herois;
  final int campanhas;
  final int? sessoes;
  final VoidCallback onEditar;
  final VoidCallback onEntrar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              AvatarCircle(imagePath: usuario.avatar, radius: 34),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      usuario.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Etiqueta(
                      usuario.papel.label,
                      pequena: true,
                      selecionado: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              IconButton(
                tooltip: 'Editar perfil',
                onPressed: onEditar,
                icon: const Icon(Pixel.pencil, color: AppColors.alerta),
              ),
            ],
          ),
          const Divider(),
          IntrinsicHeight(
            child: Row(
              children: [
                _Contador(rotulo: 'Heróis', valor: '$herois'),
                const _Separador(),
                _Contador(rotulo: 'Campanhas', valor: '$campanhas'),
                const _Separador(),
                _Contador(rotulo: 'Sessões', valor: sessoes?.toString() ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          _AvisoPerfilLocal(onEntrar: onEntrar),
        ],
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rotulo.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.alerta,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      color: AppColors.secondary.withValues(alpha: 0.3),
    );
  }
}

class _AvisoPerfilLocal extends StatelessWidget {
  const _AvisoPerfilLocal({required this.onEntrar});

  final VoidCallback onEntrar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Row(
        children: [
          const Icon(Pixel.lock, size: 18, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.small + 4),
          Expanded(
            flex: 3,
            child: Text(
              'Perfil local: tudo fica salvo só neste aparelho.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.onSurface),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Flexible(
            flex: 2,
            child: InkWell(
              onTap: onEntrar,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  'Entrar · em breve',
                  textAlign: TextAlign.end,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.45),
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
