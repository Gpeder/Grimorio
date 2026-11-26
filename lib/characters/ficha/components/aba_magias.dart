import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/gemas_magia.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/models/hero_options_mock.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';

const _imagemEscola = {
  'Abjuração': AppImages.magoAbjuracao,
  'Adivinhação': AppImages.magoAdivinhacao,
  'Conjuração': AppImages.magoConjuracao,
  'Encantamento': AppImages.magoEncantamento,
  'Evocação': AppImages.magoEvocacao,
  'Ilusão': AppImages.magoIlusao,
  'Necromancia': AppImages.magoNecromancia,
  'Transmutação': AppImages.magoTransmutacao,
};

enum _Filtro {
  preparadas('Preparadas'),
  todas('Todas'),
  truques('Truques', 0),
  primeiro('1º', 1),
  segundo('2º', 2),
  terceiro('3º', 3);

  const _Filtro(this.rotulo, [this.circulo]);
  final String rotulo;
  final int? circulo;
}

class AbaMagias extends StatefulWidget {
  const AbaMagias({
    super.key,
    required this.personagem,
    required this.onGastar,
    required this.onRecuperar,
    required this.onAlternarPreparada,
  });

  final Character personagem;
  final ValueChanged<int> onGastar;
  final ValueChanged<int> onRecuperar;
  final ValueChanged<String> onAlternarPreparada;

  @override
  State<AbaMagias> createState() => _AbaMagiasState();
}

class _AbaMagiasState extends State<AbaMagias> {
  _Filtro _filtro = _Filtro.preparadas;

  Character get _p => widget.personagem;

  bool _preparada(SpellOption m) =>
      m.circulo == 0 || _p.magiasPreparadas.contains(m.key);

  bool _passa(SpellOption m) => switch (_filtro) {
    _Filtro.preparadas => _preparada(m),
    _Filtro.todas => true,
    _ => m.circulo == _filtro.circulo,
  };

  void _detalhes(SpellOption m) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheet) => _DetalhesMagia(
        magia: m,
        preparada: _p.magiasPreparadas.contains(m.key),
        onAlternar: () {
          Navigator.pop(sheet);
          widget.onAlternarPreparada(m.key);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = _p;
    final conhecidas = [for (final k in p.magias) ?magiaPorKey(k)];

    if (p.espacosDeMagia.isEmpty && conhecidas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.large),
        child: Center(
          child: Column(
            children: [
              const ImageFrame(
                imagePath: AppImages.grimorio,
                width: 96,
                height: 96,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Esta classe não usa magia',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = p.espacosDeMagia.fold(0, (s, e) => s + e.total);
    final naoTruques = conhecidas.where((m) => m.circulo > 0);
    final preparadas = naoTruques.where(_preparada).length;

    final filtradas = conhecidas.where(_passa).toList()
      ..sort((a, b) {
        final c = a.circulo.compareTo(b.circulo);
        return c != 0 ? c : a.nome.compareTo(b.nome);
      });
    final circulos = {for (final m in filtradas) m.circulo};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Espaços de magia',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${p.espacosLivres} de $total livres',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.alerta,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              GemasMagia(
                espacos: p.espacosDeMagia,
                onGastar: widget.onGastar,
                onRecuperar: widget.onRecuperar,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Toque numa gema para gastar ou recuperar.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Divider(height: AppSpacing.large),
              Row(
                children: [
                  Expanded(
                    child: _Numero(
                      rotulo: 'Ataque mágico',
                      valor: sinal(p.ataqueMagico),
                    ),
                  ),
                  Expanded(
                    child: _Numero(
                      rotulo: 'CD de magia',
                      valor: '${p.cdMagia}',
                    ),
                  ),
                  Expanded(
                    child: _Numero(
                      rotulo: 'Preparadas',
                      valor: '$preparadas / ${naoTruques.length}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 6,
            children: [
              for (final f in _Filtro.values)
                Etiqueta(
                  f.rotulo,
                  selecionado: f == _filtro,
                  onTap: () => setState(() => _filtro = f),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        if (filtradas.isEmpty)
          Text(
            'Nenhuma magia aqui.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        for (final c in circulos) ...[
          TituloSecao(c == 0 ? 'Truques' : '$cº círculo'),
          for (final m in filtradas)
            if (m.circulo == c)
              _LinhaMagia(
                magia: m,
                apagada: !_preparada(m),
                onTap: () => _detalhes(m),
              ),
          const SizedBox(height: AppSpacing.medium),
        ],
      ],
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotuloFicha(rotulo),
        const SizedBox(height: 2),
        Text(
          valor,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required this.magia});

  final SpellOption magia;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (magia.concentracao)
          const Etiqueta('C', pequena: true, cor: AppColors.mana),
        if (magia.ritual)
          const Etiqueta('R', pequena: true, cor: AppColors.mana),
      ],
    );
  }
}

class _LinhaMagia extends StatelessWidget {
  const _LinhaMagia({
    required this.magia,
    required this.apagada,
    required this.onTap,
  });

  final SpellOption magia;
  final bool apagada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: apagada ? 0.5 : 1,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
              child: Row(
                children: [
                  ImageFrame(
                    imagePath: _imagemEscola[magia.escola],
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: AppSpacing.medium - 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                magia.nome,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _Tags(magia: magia),
                          ],
                        ),
                        Text(
                          magia.linha,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _DetalhesMagia extends StatelessWidget {
  const _DetalhesMagia({
    required this.magia,
    required this.preparada,
    required this.onAlternar,
  });

  final SpellOption magia;
  final bool preparada;
  final VoidCallback onAlternar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = magia;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.large,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImageFrame(
                  imagePath: _imagemEscola[m.escola],
                  width: 64,
                  height: 64,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.nome,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${m.escola} · '
                        '${m.circulo == 0 ? 'truque' : '${m.circulo}º círculo'}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.alerta,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              m.resumo,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
            ),
            if (m.concentracao || m.ritual) ...[
              const SizedBox(height: AppSpacing.small),
              _Tags(magia: m),
            ],
            if (m.circulo > 0) ...[
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAlternar,
                  child: Text(preparada ? 'Despreparar' : 'Preparar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
