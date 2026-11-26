import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/new_hero/components/alternador.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/view/characters/new_hero/components/grade_imagens.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

class PassoIdentidade extends StatelessWidget {
  const PassoIdentidade({
    super.key,
    required this.nome,
    required this.retrato,
    required this.feminino,
    required this.alinhamento,
    required this.alinhamentos,
    required this.idiomas,
    required this.idiomasDisponiveis,
    required this.qtdeIdiomas,
    required this.origemIdiomas,
    required this.historia,
    required this.onNome,
    required this.onFeminino,
    required this.onRetrato,
    required this.onAlinhamento,
    required this.onIdioma,
    required this.onHistoria,
  });

  final String nome;
  final String? retrato;
  final bool feminino;
  final String? alinhamento;
  final List<String> alinhamentos;
  final Set<String> idiomas;
  final List<String> idiomasDisponiveis;
  final int qtdeIdiomas;

  final String origemIdiomas;
  final String historia;
  final ValueChanged<String> onNome;
  final ValueChanged<bool> onFeminino;
  final ValueChanged<String> onRetrato;
  final ValueChanged<String> onAlinhamento;
  final ValueChanged<String> onIdioma;
  final ValueChanged<String> onHistoria;

  Future<void> _trocarRetrato(BuildContext context) async {
    final escolhido = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RotuloSecao('Escolha o retrato'),
              const SizedBox(height: AppSpacing.small),
              GradeImagens(
                colunas: 4,
                itens: [
                  for (final r in AppImages.especies)
                    ItemImagem(
                      imagem: r,
                      selecionado: r == retrato,
                      onTap: () => Navigator.pop(context, r),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (escolhido != null) onRetrato(escolhido);
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RotuloSecao('Nome'),
          TextFormField(
            key: const ValueKey('nome'),
            initialValue: nome,
            textCapitalization: TextCapitalization.words,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: 'Nome do herói'),
            onChanged: onNome,
          ),
          const SizedBox(height: AppSpacing.medium - 4),
          const RotuloSecao('Retrato'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageFrame(
                imagePath: retrato,
                selected: true,
                width: 88,
                height: 112,
                onTap: () => _trocarRetrato(context),
              ),
              const SizedBox(width: AppSpacing.medium - 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Alternador<bool>(
                      opcoes: const {true: 'Feminino', false: 'Masculino'},
                      valor: feminino,
                      onChanged: onFeminino,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    TextButton(
                      onPressed: () => _trocarRetrato(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Trocar retrato'),
                          Icon(Pixel.chevronright, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium - 4),
          const RotuloSecao('Alinhamento'),
          _GradeAlinhamento(
            alinhamentos: alinhamentos,
            valor: alinhamento,
            onChanged: onAlinhamento,
          ),
          if (qtdeIdiomas > 0) ...[
            const SizedBox(height: AppSpacing.medium - 4),
            RotuloSecao(
              'Idiomas extras · escolha $qtdeIdiomas ($origemIdiomas)',
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final i in idiomasDisponiveis)
                  Etiqueta(
                    i,
                    selecionado: idiomas.contains(i),
                    onTap: idiomas.contains(i) || idiomas.length < qtdeIdiomas
                        ? () => onIdioma(i)
                        : null,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.medium - 4),
          const RotuloSecao('História (opcional)'),
          TextFormField(
            key: const ValueKey('historia'),
            initialValue: historia,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'De onde veio, o que busca…',
            ),
            onChanged: onHistoria,
          ),
        ],
      ),
    );
  }
}

class _GradeAlinhamento extends StatelessWidget {
  const _GradeAlinhamento({
    required this.alinhamentos,
    required this.valor,
    required this.onChanged,
  });

  final List<String> alinhamentos;
  final String? valor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      spacing: 6,
      children: [
        for (var linha = 0; linha < 3; linha++)
          Row(
            spacing: 6,
            children: [
              for (var col = 0; col < 3; col++)
                Expanded(
                  child: CaixaOpcao(
                    selecionado: alinhamentos[linha * 3 + col] == valor,
                    onTap: () => onChanged(alinhamentos[linha * 3 + col]),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Text(
                      alinhamentos[linha * 3 + col],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
