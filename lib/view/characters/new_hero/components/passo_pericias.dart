import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/view/characters/new_hero/components/check_tile.dart';
import 'package:grimorio/widgets/etiqueta.dart';

class PassoPericias extends StatelessWidget {
  const PassoPericias({
    super.key,
    required this.classe,
    required this.travadas,
    required this.escolhidas,
    required this.livres,
    required this.escolhidasLivres,
    required this.bonus,
    required this.outras,
    required this.onPericia,
    required this.onPericiaLivre,
  });

  final OpcaoClasse classe;

  final Map<String, String> travadas;
  final Set<String> escolhidas;

  final int livres;
  final Set<String> escolhidasLivres;
  final int Function(String pericia) bonus;

  final List<String> outras;
  final ValueChanged<String> onPericia;
  final ValueChanged<String> onPericiaLivre;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final n = classe.qtdePericias;
    final listaClasse = [
      for (final p in periciasMock)
        if ((classe.pericias.isEmpty || classe.pericias.contains(p.nome)) &&
            !travadas.containsKey(p.nome) &&
            !escolhidasLivres.contains(p.nome))
          p,
    ];
    final listaLivre = [
      for (final p in periciasMock)
        if (!travadas.containsKey(p.nome) && !escolhidas.contains(p.nome)) p,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Contador(
            texto: 'Escolha $n perícias de ${classe.nome}',
            atual: escolhidas.length,
            total: n,
          ),
          const SizedBox(height: AppSpacing.small),
          for (final MapEntry(key: nome, value: origem) in travadas.entries)
            _Linha(
              pericia: _buscar(nome),
              marcado: true,
              travado: true,
              origem: origem,
              bonus: bonus(nome),
            ),
          for (final p in listaClasse)
            _Linha(
              pericia: p,
              marcado: escolhidas.contains(p.nome),
              bonus: bonus(p.nome),
              onChanged: escolhidas.contains(p.nome) || escolhidas.length < n
                  ? (_) => onPericia(p.nome)
                  : null,
            ),
          if (livres > 0) ...[
            const SizedBox(height: AppSpacing.medium),
            _Contador(
              texto: 'Escolha $livres perícias quaisquer (espécie)',
              atual: escolhidasLivres.length,
              total: livres,
            ),
            const SizedBox(height: AppSpacing.small),
            for (final p in listaLivre)
              _Linha(
                pericia: p,
                marcado: escolhidasLivres.contains(p.nome),
                bonus: bonus(p.nome),
                onChanged:
                    escolhidasLivres.contains(p.nome) ||
                        escolhidasLivres.length < livres
                    ? (_) => onPericiaLivre(p.nome)
                    : null,
              ),
          ],
          const SizedBox(height: AppSpacing.medium),
          const RotuloSecao('Outras proficiências'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final o in outras) Etiqueta(o)],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Bônus = modificador do atributo + $proficienciaNivel1 '
            'de proficiência.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  static OpcaoPericia _buscar(String nome) =>
      periciasMock.firstWhere((p) => p.nome == nome);
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.texto,
    required this.atual,
    required this.total,
  });

  final String texto;
  final int atual;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CaixaOpcao(
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
            ),
          ),
          Text(
            '$atual / $total',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: atual == total ? AppColors.sucesso : AppColors.alerta,
            ),
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.pericia,
    required this.marcado,
    required this.bonus,
    this.travado = false,
    this.origem,
    this.onChanged,
  });

  final OpcaoPericia pericia;
  final bool marcado;
  final bool travado;
  final String? origem;
  final int bonus;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final origem = this.origem;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: CheckTile(
        marcado: marcado,
        travado: travado,
        onChanged: onChanged,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              child: Text(
                pericia.atributo.sigla,
                textAlign: TextAlign.center,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                sinal(bonus),
                textAlign: TextAlign.right,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                pericia.nome,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (origem != null) ...[
              const SizedBox(width: 6),
              Etiqueta(origem, pequena: true, cor: AppColors.onSurface),
            ],
          ],
        ),
      ),
    );
  }
}
