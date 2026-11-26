import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/image_frame.dart';

// tela cheia para id ou rota que nao existe
class EstadoNaoEncontrado extends StatelessWidget {
  const EstadoNaoEncontrado({super.key, this.onVoltar});

  // sem callback volta uma tela ou vai pro inicio
  final VoidCallback? onVoltar;

  void _voltar(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(Rotas.inicio);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ImageFrame(
                  imagePath: AppImages.menuMapa,
                  width: 96,
                  height: 96,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Não encontrado',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Esse caminho não leva a lugar nenhum.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                OutlinedButton(
                  onPressed: onVoltar ?? () => _voltar(context),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
