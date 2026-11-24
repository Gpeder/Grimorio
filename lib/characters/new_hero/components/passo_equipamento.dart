import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/new_hero/components/alternador.dart';
import 'package:grimorio/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/widgets/image_frame.dart';

class PassoEquipamento extends StatelessWidget {
  const PassoEquipamento({
    super.key,
    required this.classe,
    required this.modoOuro,
    required this.escolhas,
    required this.ouro,
    required this.onModoOuro,
    required this.onEscolha,
    required this.onOuro,
  });

  final ClassOption classe;
  final bool modoOuro;

  final Map<int, String> escolhas;
  final int? ouro;
  final ValueChanged<bool> onModoOuro;
  final void Function(int escolha, String key) onEscolha;
  final ValueChanged<int?> onOuro;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nota = textTheme.bodySmall?.copyWith(
      color: AppColors.onSurface.withValues(alpha: 0.6),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (classe.temPacote) ...[
            Alternador<bool>(
              opcoes: const {false: 'Pacote da classe', true: 'Ouro inicial'},
              valor: modoOuro,
              onChanged: onModoOuro,
            ),
            const SizedBox(height: AppSpacing.medium - 4),
          ] else ...[
            Text(
              '${classe.nome} começa só com ouro.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.medium - 4),
          ],
          if (modoOuro || !classe.temPacote) ...[
            TextFormField(
              key: const ValueKey('ouro'),
              initialValue: ouro?.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Ouro que você rolou na mesa',
                suffixText: 'po',
              ),
              onChanged: (v) => onOuro(int.tryParse(v)),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Role o ouro inicial da classe na mesa e digite o total.',
              style: nota,
            ),
          ] else ...[
            for (var i = 0; i < classe.equipamento.length; i++) ...[
              RotuloSecao('Escolha ${i + 1}'),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.small,
                  children: [
                    for (final item in classe.equipamento[i].opcoes)
                      Expanded(
                        child: CaixaOpcao(
                          selecionado: escolhas[i] == item.key,
                          onTap: () => onEscolha(i, item.key),
                          padding: const EdgeInsets.all(AppSpacing.small),
                          child: Row(
                            children: [
                              ImageFrame(imagePath: item.imagem, width: 36),
                              const SizedBox(width: AppSpacing.small),
                              Expanded(
                                child: Text(
                                  item.nome,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium - 4),
            ],
            const RotuloSecao('Sempre incluso'),
            Row(
              children: [
                for (final item in classe.sempreIncluso) ...[
                  ImageFrame(imagePath: item.imagem, width: 36),
                  const SizedBox(width: 6),
                ],
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    classe.sempreIncluso.map((i) => i.nome).join(', '),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium - 4),
            Text(
              'No modo Ouro inicial, você digita o ouro que rolou na mesa.',
              style: nota,
            ),
          ],
        ],
      ),
    );
  }
}
