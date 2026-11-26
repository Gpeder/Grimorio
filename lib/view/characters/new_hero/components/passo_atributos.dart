import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/characters/gerenciador_criacao.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/new_hero/components/alternador.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:pixelarticons/pixel.dart';

class PassoAtributos extends StatelessWidget {
  const PassoAtributos({
    super.key,
    required this.modo,
    required this.base,
    required this.total,
    required this.rotuloBonus,
    required this.principal,
    required this.dica,
    required this.bonusLivres,
    required this.escolhidosLivres,
    required this.onModo,
    required this.onValor,
    required this.onBonusLivre,
  });

  final ModoAtributos modo;
  final Map<Atributo, int?> base;

  final int? Function(Atributo) total;

  final String? Function(Atributo) rotuloBonus;
  final Atributo? principal;
  final String? dica;

  final int bonusLivres;
  final Set<Atributo> escolhidosLivres;
  final ValueChanged<ModoAtributos> onModo;
  final void Function(Atributo, int?) onValor;
  final ValueChanged<Atributo> onBonusLivre;

  static const _larguraSigla = 48.0;
  static const _larguraTotal = 40.0;
  static const _larguraMod = 40.0;

  double get _larguraCampo => modo == ModoAtributos.compra ? 112 : 76;

  String get _textoModo => switch (modo) {
    ModoAtributos.rolagem =>
      'Role seus dados na mesa e digite o resultado da rolagem de cada '
          'atributo. O bônus da espécie é somado depois.',
    ModoAtributos.compra =>
      'Distribua $limiteCompra pontos em valores de 8 a 15.',
    ModoAtributos.array =>
      'Use cada valor do array padrão (${arrayPadrao.join(', ')}) uma vez.',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rotuloEstilo = textTheme.labelSmall?.copyWith(
      color: AppColors.onSurface.withValues(alpha: 0.6),
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
    final gastos = GerenciadorCriacao.pontosGastos(base.values);
    final dica = this.dica;

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
          Alternador<ModoAtributos>(
            opcoes: const {
              ModoAtributos.rolagem: 'Rolei na mesa',
              ModoAtributos.compra: 'Compra 27 pts',
              ModoAtributos.array: 'Array padrão',
            },
            valor: modo,
            onChanged: onModo,
          ),
          const SizedBox(height: AppSpacing.medium - 4),
          Text(
            _textoModo,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.75),
            ),
          ),
          if (modo == ModoAtributos.compra) ...[
            const SizedBox(height: AppSpacing.small),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Pontos ${gastos ?? '—'} / $limiteCompra',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: gastos != null && gastos <= limiteCompra
                      ? AppColors.sucesso
                      : AppColors.vida,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.medium - 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
            child: Row(
              children: [
                const SizedBox(width: _larguraSigla),
                SizedBox(
                  width: _larguraCampo,
                  child: Text(
                    switch (modo) {
                      ModoAtributos.rolagem => 'ROLAGEM',
                      ModoAtributos.compra => 'COMPRA',
                      ModoAtributos.array => 'ARRAY',
                    },
                    textAlign: TextAlign.center,
                    style: rotuloEstilo,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.small),
                    child: Text('BÔNUS', style: rotuloEstilo),
                  ),
                ),
                SizedBox(
                  width: _larguraTotal,
                  child: Text(
                    'TOTAL',
                    textAlign: TextAlign.center,
                    style: rotuloEstilo,
                  ),
                ),
                SizedBox(
                  width: _larguraMod,
                  child: Text(
                    'MOD',
                    textAlign: TextAlign.right,
                    style: rotuloEstilo,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          for (final a in Atributo.values) ...[
            _Linha(
              atributo: a,
              modo: modo,
              valor: base[a],
              base: base,
              total: total(a),
              rotuloBonus: rotuloBonus(a),
              principal: a == principal,
              larguraCampo: _larguraCampo,
              onValor: (v) => onValor(a, v),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          if (bonusLivres > 0) ...[
            const SizedBox(height: AppSpacing.small),
            RotuloSecao(
              '+1 em $bonusLivres atributos · '
              '${escolhidosLivres.length} / $bonusLivres',
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in Atributo.values)
                  if (a != Atributo.carisma)
                    Etiqueta(
                      a.sigla,
                      selecionado: escolhidosLivres.contains(a),
                      onTap:
                          escolhidosLivres.contains(a) ||
                              escolhidosLivres.length < bonusLivres
                          ? () => onBonusLivre(a)
                          : null,
                    ),
              ],
            ),
          ],
          if (dica != null) ...[
            const SizedBox(height: AppSpacing.medium - 4),
            Text(
              dica,
              style: textTheme.bodySmall?.copyWith(color: AppColors.secondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.atributo,
    required this.modo,
    required this.valor,
    required this.base,
    required this.total,
    required this.rotuloBonus,
    required this.principal,
    required this.larguraCampo,
    required this.onValor,
  });

  final Atributo atributo;
  final ModoAtributos modo;
  final int? valor;
  final Map<Atributo, int?> base;
  final int? total;
  final String? rotuloBonus;
  final bool principal;
  final double larguraCampo;
  final ValueChanged<int?> onValor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = this.total;
    final rotuloBonus = this.rotuloBonus;

    return CaixaOpcao(
      selecionado: principal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: PassoAtributos._larguraSigla,
            child: Text(
              atributo.sigla,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: larguraCampo,
            child: switch (modo) {
              ModoAtributos.rolagem => _CampoRolagem(
                atributo: atributo,
                valor: valor,
                onValor: onValor,
              ),
              ModoAtributos.compra => _CampoCompra(
                valor: valor ?? 8,
                onValor: onValor,
              ),
              ModoAtributos.array => _CampoArray(
                atributo: atributo,
                valor: valor,
                base: base,
                onValor: onValor,
              ),
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.small),
              child: Text(
                rotuloBonus ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.sucesso,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            width: PassoAtributos._larguraTotal,
            child: Text(
              total?.toString() ?? '—',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: PassoAtributos._larguraMod,
            child: Text(
              total == null ? '' : sinal(modificador(total)),
              textAlign: TextAlign.right,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.alerta,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoRolagem extends StatelessWidget {
  const _CampoRolagem({
    required this.atributo,
    required this.valor,
    required this.onValor,
  });

  final Atributo atributo;
  final int? valor;
  final ValueChanged<int?> onValor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Resultado da rolagem de ${nomeAtributo[atributo]}',
      child: TextFormField(
        key: ValueKey('rolagem-${atributo.name}'),
        initialValue: valor?.toString(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          isDense: true,
          hintText: '—',
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (v) => onValor(int.tryParse(v)),
      ),
    );
  }
}

class _CampoCompra extends StatelessWidget {
  const _CampoCompra({required this.valor, required this.onValor});

  final int valor;
  final ValueChanged<int?> onValor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: valor > 8 ? () => onValor(valor - 1) : null,
          icon: const Icon(Pixel.minus, semanticLabel: 'Diminuir'),
          iconSize: 14,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          '$valor',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: valor < 15 ? () => onValor(valor + 1) : null,
          icon: const Icon(Pixel.plus, semanticLabel: 'Aumentar'),
          iconSize: 14,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _CampoArray extends StatelessWidget {
  const _CampoArray({
    required this.atributo,
    required this.valor,
    required this.base,
    required this.onValor,
  });

  final Atributo atributo;
  final int? valor;
  final Map<Atributo, int?> base;
  final ValueChanged<int?> onValor;

  @override
  Widget build(BuildContext context) {
    final usados = {
      for (final MapEntry(:key, :value) in base.entries)
        if (key != atributo && value != null) value,
    };

    return DropdownButton<int>(
      value: valor,
      isExpanded: true,
      hint: const Center(child: Text('—')),
      items: [
        for (final v in arrayPadrao)
          if (!usados.contains(v))
            DropdownMenuItem(
              value: v,
              child: Center(child: Text('$v')),
            ),
      ],
      onChanged: onValor,
    );
  }
}
