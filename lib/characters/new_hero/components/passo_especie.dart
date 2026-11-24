import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/new_hero/components/alternador.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/characters/new_hero/components/grade_imagens.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/models/hero_options_mock.dart';
import 'package:grimorio/widgets/appcard.dart';

class PassoEspecie extends StatelessWidget {
  const PassoEspecie({
    super.key,
    required this.especie,
    required this.subespecieKey,
    required this.feminino,
    required this.onEspecie,
    required this.onSubespecie,
    required this.onFeminino,
  });

  final SpeciesOption? especie;
  final String? subespecieKey;
  final bool feminino;
  final ValueChanged<SpeciesOption> onEspecie;
  final ValueChanged<String> onSubespecie;
  final ValueChanged<bool> onFeminino;

  @override
  Widget build(BuildContext context) {
    final especie = this.especie;

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Alternador<bool>(
              opcoes: const {true: 'Feminino', false: 'Masculino'},
              valor: feminino,
              onChanged: onFeminino,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: GradeImagens(
                itens: [
                  for (final e in especiesMock)
                    ItemImagem(
                      imagem: e.retratoPara(feminino: feminino),
                      rotulo: e.nome,
                      selecionado: e.key == especie?.key,
                      onTap: () => onEspecie(e),
                    ),
                ],
              ),
            ),
          ),
          if (especie != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.45,
              ),
              child: SingleChildScrollView(
                child: _Painel(
                  especie: especie,
                  subespecieKey: subespecieKey,
                  onSubespecie: onSubespecie,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({
    required this.especie,
    required this.subespecieKey,
    required this.onSubespecie,
  });

  final SpeciesOption especie;
  final String? subespecieKey;
  final ValueChanged<String> onSubespecie;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final deslocamento = especie.deslocamentoM
        .toStringAsFixed(especie.deslocamentoM % 1 == 0 ? 0 : 1)
        .replaceAll('.', ',');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  especie.nome,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${especie.tamanho} · $deslocamento m',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            especie.descricao,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in especie.tracos) Etiqueta(t)],
          ),
          if (especie.subespecies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.medium - 4),
            const RotuloSecao('Sub-espécie'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in especie.subespecies)
                  Etiqueta(
                    s.nome,
                    selecionado: s.key == subespecieKey,
                    onTap: () => onSubespecie(s.key),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
