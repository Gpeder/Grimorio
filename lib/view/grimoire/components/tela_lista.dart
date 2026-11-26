import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/grimoire/components/busca_compendio.dart';
import 'package:pixelarticons/pixel.dart';

// base das listas do grimorio
class TelaLista extends StatelessWidget {
  const TelaLista({
    super.key,
    required this.titulo,
    required this.contagem,
    required this.itens,
    this.dicaBusca,
    this.onBusca,
    this.filtros = const [],
  });

  final String titulo;
  final int contagem;
  final String? dicaBusca;
  final ValueChanged<String>? onBusca;
  final List<Widget> filtros;
  final List<Widget> itens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dicaBusca = this.dicaBusca;
    final onBusca = this.onBusca;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoltarHeader(
              titulo: titulo,
              direita: Text(
                '$contagem',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.small,
                children: [
                  if (dicaBusca != null && onBusca != null)
                    BuscaCompendio(dica: dicaBusca, onChanged: onBusca),
                  ...filtros,
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.medium,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                child: itens.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.large),
                        child: Text(
                          'Nada encontrado.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: itens,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// topo das telas internas
class VoltarHeader extends StatelessWidget {
  const VoltarHeader({super.key, this.titulo, this.direita});

  final String? titulo;
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    final titulo = this.titulo;
    final direita = this.direita;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.small,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.small,
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.small),
              child: Icon(
                Pixel.chevronleft,
                color: AppColors.onSurface,
                semanticLabel: 'Voltar',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: titulo == null
                ? const SizedBox.shrink()
                : Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          ?direita,
        ],
      ),
    );
  }
}

// botao fixo no rodapé
class RodapeButton extends StatelessWidget {
  const RodapeButton({super.key, required this.texto, required this.onPressed});

  final String texto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.25)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ElevatedButton(onPressed: onPressed, child: Text(texto)),
        ),
      ),
    );
  }
}
