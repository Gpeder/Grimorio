import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/characters/new_hero/components/grade_imagens.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/models/hero_options_mock.dart';
import 'package:grimorio/widgets/appcard.dart';

class PassoClasse extends StatelessWidget {
  const PassoClasse({
    super.key,
    required this.classe,
    required this.subclasseKey,
    required this.onClasse,
    required this.onSubclasse,
  });

  final ClassOption? classe;
  final String? subclasseKey;
  final ValueChanged<ClassOption> onClasse;
  final ValueChanged<String> onSubclasse;

  @override
  Widget build(BuildContext context) {
    final classe = this.classe;

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                0,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua classe define vida, proficiências e magia.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium - 4),
                  GradeImagens(
                    colunas: 4,
                    itens: [
                      for (final c in classesMock)
                        ItemImagem(
                          imagem: c.imagem,
                          rotulo: c.nome,
                          selecionado: c.key == classe?.key,
                          onTap: () => onClasse(c),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (classe != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.55,
              ),
              child: SingleChildScrollView(
                child: _Painel(
                  classe: classe,
                  subclasseKey: subclasseKey,
                  onSubclasse: onSubclasse,
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
    required this.classe,
    required this.subclasseKey,
    required this.onSubclasse,
  });

  final ClassOption classe;
  final String? subclasseKey;
  final ValueChanged<String> onSubclasse;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final salvaguardas = classe.salvaguardas.map((a) => a.sigla).join(' e ');
    final rotulo = classe.rotuloSubclasse;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  classe.nome,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'd${classe.dadoDeVida} · ${nomeAtributo[classe.principal]}',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.alerta,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Etiqueta('Salv. $salvaguardas'),
              for (final p in classe.proficiencias) Etiqueta(p),
            ],
          ),
          if (rotulo != null) ...[
            const Divider(),
            RotuloSecao('$rotulo · escolhido no nível 1'),
            const SizedBox(height: 4),
            GradeImagens(
              colunas: 4,
              itens: [
                for (final s in classe.subclasses)
                  ItemImagem(
                    imagem: s.imagem,
                    rotulo: s.nome,
                    selecionado: s.key == subclasseKey,
                    onTap: () => onSubclasse(s.key),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
