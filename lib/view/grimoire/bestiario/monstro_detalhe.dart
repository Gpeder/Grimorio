import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/grimoire.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';

String milhar(int n) {
  final d = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i > 0 && (d.length - i) % 3 == 0) b.write('.');
    b.write(d[i]);
  }
  return b.toString();
}

// "+4", "−1": sinal tipográfico, como num statblock.
String _mod(int valor) {
  final m = modificador(valor);
  return m < 0 ? '−${-m}' : '+$m';
}

class MonstroDetalhe extends StatelessWidget {
  const MonstroDetalhe({super.key, required this.monstro});

  final Monstro monstro;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = monstro;
    final divisor = Divider(
      height: AppSpacing.large,
      color: AppColors.vida.withValues(alpha: 0.7),
    );

    return Scaffold(
      bottomNavigationBar: BotaoRodape(
        texto: 'Adicionar ao encontro',
        onPressed: () => mostrarAviso(context, 'Em breve'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarraVoltar(
              direita: Text(
                'ND ${m.nd} · ${milhar(m.xp)} XP',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  0,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ImageFrame(imagePath: m.imagem, width: 80, height: 80),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.nome,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${m.tipo} ${m.tamanho}, ${m.alinhamento}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.medium - 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          _Linha(
                            'Classe de Armadura',
                            m.caDetalhe.isEmpty
                                ? '${m.ca}'
                                : '${m.ca} (${m.caDetalhe})',
                          ),
                          _Linha('Pontos de Vida', '${m.pv} (${m.pvDado})'),
                          _Linha('Deslocamento', m.deslocamento),
                          divisor,
                          Row(
                            children: [
                              for (final a in Ability.values)
                                Expanded(
                                  child: _Atributo(
                                    sigla: a.sigla,
                                    valor: m.atributos.valor(a),
                                  ),
                                ),
                            ],
                          ),
                          divisor,
                          if (m.sentidos.isNotEmpty)
                            _Linha('Sentidos', m.sentidos.join(', ')),
                          _Linha(
                            'Idiomas',
                            m.idiomas.isEmpty ? '—' : m.idiomas.join(', '),
                          ),
                          _Linha(
                            'Nível de desafio',
                            '${m.nd} (${milhar(m.xp)} XP)',
                          ),
                        ],
                      ),
                    ),
                    if (m.tracos.isNotEmpty)
                      _Secao(titulo: 'Traços', acoes: m.tracos),
                    if (m.acoes.isNotEmpty)
                      _Secao(titulo: 'Ações', acoes: m.acoes),
                    if (m.acoesLendarias.isNotEmpty)
                      _Secao(
                        titulo: 'Ações lendárias',
                        acoes: m.acoesLendarias,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.rotulo, this.valor);

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodyMedium;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$rotulo ',
            style: estilo?.copyWith(
              color: AppColors.alerta,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: valor,
            style: estilo?.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _Atributo extends StatelessWidget {
  const _Atributo({required this.sigla, required this.valor});

  final String sigla;
  final int valor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          sigla,
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$valor',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _mod(valor),
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.acoes});

  final String titulo;
  final List<AcaoMonstro> acoes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.vida.withValues(alpha: 0.7),
                ),
              ),
            ),
            child: Text(
              titulo,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.vida,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final a in acoes)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.medium - 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${a.nome}. ',
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: a.descricao,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (a.ataque != null || a.dano != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (a.ataque case final ataque?) Etiqueta(ataque),
                        if (a.dano case final dano?)
                          Etiqueta(dano, cor: AppColors.vida),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
