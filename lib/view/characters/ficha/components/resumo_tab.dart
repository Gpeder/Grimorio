import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/ficha/components/medalhao_atributo.dart';
import 'package:grimorio/view/characters/ficha/components/numero_dialog.dart';
import 'package:grimorio/view/characters/ficha/components/pericia_tile.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

class ResumoTab extends StatelessWidget {
  const ResumoTab({
    super.key,
    required this.personagem,
    required this.onInspiracao,
    required this.onCurar,
    required this.onDescansoLongo,
    required this.onVerPericias,
  });

  final Personagem personagem;
  final VoidCallback onInspiracao;
  final ValueChanged<int> onCurar;
  final VoidCallback onDescansoLongo;
  final VoidCallback onVerPericias;

  static const _espaco = SizedBox(height: AppSpacing.large);

  Atributo get _destaque =>
      personagem.atributoMagia ??
      Atributo.values.reduce(
        (a, b) => personagem.atributos.valor(b) > personagem.atributos.valor(a)
            ? b
            : a,
      );

  Future<void> _descansoCurto(BuildContext context) async {
    final valor = await pedirNumero(
      context,
      titulo: 'Descanso curto',
      dica:
          'Quanto de vida você recuperou? '
          '(role seus dados de vida na mesa)',
    );
    if (valor != null) onCurar(valor);
  }

  Future<void> _descansoLongo(BuildContext context) async {
    final ok = await confirmar(
      context,
      titulo: 'Descanso longo',
      texto:
          'Restaura:\n'
          '• HP cheio (${personagem.hpMax})\n'
          '• Todos os espaços de magia\n'
          '• HP temporário zerado',
      sim: 'Descansar',
    );
    if (ok) onDescansoLongo();
  }

  @override
  Widget build(BuildContext context) {
    final p = personagem;
    final destaque = _destaque;
    final salvaguardas = [
      ...Atributo.values.where(p.salvaguardas.contains),
      ...Atributo.values.where((a) => !p.salvaguardas.contains(a)),
    ];
    final emDestaque = [
      for (final s in periciasMock)
        if (p.pericias.contains(s.nome) || s.nome == 'Percepção') s,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final linha in [
          Atributo.values.sublist(0, 3),
          Atributo.values.sublist(3),
        ]) ...[
          Row(
            spacing: AppSpacing.small,
            children: [
              for (final a in linha)
                Expanded(
                  child: MedalhaoAtributo(
                    atributo: a,
                    valor: p.atributos.valor(a),
                    destaque: a == destaque,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
        ],
        const SizedBox(height: AppSpacing.small),
        IntrinsicHeight(
          child: Row(
            spacing: AppSpacing.small,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Caixa(
                  rotulo: 'Profic.',
                  child: _Numero(sinal(p.bonusProficiencia)),
                ),
              ),
              Expanded(
                child: _Caixa(
                  rotulo: 'Percep. passiva',
                  child: _Numero('${p.percepcaoPassiva}'),
                ),
              ),
              Expanded(
                child: _Caixa(
                  rotulo: 'Inspiração',
                  onTap: onInspiracao,
                  child: Icon(
                    Pixel.sparkle,
                    size: 26,
                    color: p.inspiracao
                        ? AppColors.alerta
                        : AppColors.onSurface.withValues(alpha: 0.25),
                    semanticLabel: p.inspiracao
                        ? 'Inspiração ativa'
                        : 'Sem inspiração',
                  ),
                ),
              ),
            ],
          ),
        ),
        _espaco,
        const TituloSecao('Salvaguardas'),
        for (final a in salvaguardas)
          PericiaTile(
            nome: nomeAtributo[a]!,
            sigla: a.sigla,
            bonus: p.salvaguarda(a),
            proficiente: p.salvaguardas.contains(a),
          ),
        _espaco,
        const TituloSecao('Perícias em destaque'),
        for (final s in emDestaque)
          PericiaTile(
            nome: s.nome,
            sigla: s.atributo.sigla,
            bonus: p.bonusPericia(s.nome),
            proficiente: p.pericias.contains(s.nome),
          ),
        const SizedBox(height: AppSpacing.medium - 4),
        TextButton(
          onPressed: onVerPericias,
          child: Text('Ver as ${periciasMock.length} perícias ›'),
        ),
        _espaco,
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.medium - 4),
          child: Column(
            children: [
              Row(
                children: [
                  const ImageFrame(
                    imagePath: AppImages.tocha,
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: AppSpacing.medium - 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descanso',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Dados de vida: ${[for (final c in p.classes) '${c.nivel}d${c.dadoDeVida}'].join(' + ')}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium - 4),
              Row(
                spacing: AppSpacing.small,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _descansoCurto(context),
                      child: const Text('Descanso curto'),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _descansoLongo(context),
                      child: const Text('Descanso longo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_temSobre) ...[_espaco, _Sobre(personagem: p)],
      ],
    );
  }

  bool get _temSobre =>
      personagem.antecedente != null ||
      personagem.alinhamento != null ||
      personagem.idiomas.isNotEmpty ||
      personagem.historia.isNotEmpty;
}

class _Caixa extends StatelessWidget {
  const _Caixa({required this.rotulo, required this.child, this.onTap});

  final String rotulo;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CaixaOpcao(
      onTap: onTap,
      corBorda: AppColors.secondary.withValues(alpha: 0.6),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.small + 2,
        horizontal: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rotulo.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
    );
  }
}

class _Sobre extends StatelessWidget {
  const _Sobre({required this.personagem});

  final Personagem personagem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = personagem;
    final suave = AppColors.onSurface.withValues(alpha: 0.6);

    Widget linha(String rotulo, String valor) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              rotulo,
              style: textTheme.bodyMedium?.copyWith(color: suave),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSecao('Sobre'),
        if (p.antecedente case final a?) linha('Antecedente', a),
        if (p.alinhamento case final a?) linha('Alinhamento', a),
        if (p.idiomas.isNotEmpty) ...[
          Text('Idiomas', style: textTheme.bodyMedium?.copyWith(color: suave)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [for (final i in p.idiomas) Etiqueta(i, pequena: true)],
          ),
        ],
        if (p.historia.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.medium),
          Text(
            p.historia,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
