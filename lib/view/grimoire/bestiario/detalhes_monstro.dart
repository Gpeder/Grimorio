import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/gerenciador_monstro.dart';
import 'package:grimorio/controller/grimoire/texto_limpo.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';
import 'package:grimorio/view/grimoire/components/tela_detalhe.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:provider/provider.dart';

const _statblock = GerenciadorMonstro();

class DetalhesMonstro extends StatefulWidget {
  const DetalhesMonstro({super.key, required this.srdKey});

  final String srdKey;

  @override
  State<DetalhesMonstro> createState() => _DetalhesMonstroState();
}

class _DetalhesMonstroState extends State<DetalhesMonstro> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  void _carregar() => context.read<CompendioProvider>().carregarDetalhe(
    TipoSrd.monstro,
    widget.srdKey,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaDetalhe<MonstroSrd>(
      estado: c.detalhe<MonstroSrd>(TipoSrd.monstro, widget.srdKey),
      onTentarDeNovo: _carregar,
      builder: (_, m) => _Conteudo(monstro: m),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.monstro});

  final MonstroSrd monstro;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = monstro;
    final atributos = m.atributos;
    final xp = m.xp;
    final nd = [
      VisualSrd.nd(m.nd),
      if (xp != null) '(${VisualSrd.milhar(xp)} XP)',
    ].join(' ');
    final divisor = Divider(
      height: AppSpacing.large,
      color: AppColors.vida.withValues(alpha: 0.7),
    );
    final sentidos = _statblock.sentidos(m);
    final salvaguardas = _statblock.salvaguardas(m);
    final pericias = _statblock.pericias(m);
    final caDetalhe = m.caDetalhe;

    return Scaffold(
      bottomNavigationBar: RodapeButton(
        texto: 'Adicionar ao encontro',
        onPressed: () => mostrarAviso(context, 'Em breve'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoltarHeader(
              direita: Text(
                'ND $nd',
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
                    // nome e tipo
                    Row(
                      children: [
                        ImageFrame(
                          imagePath: VisualSrd.monstro,
                          imagemUrl: m.imagem,
                          width: 80,
                          height: 80,
                        ),
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
                                _statblock.linhaTipo(m),
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
                    // statblock
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.medium - 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          _Linha(
                            'Classe de Armadura',
                            [
                              '${m.ca ?? TraducaoSrd.vazio}',
                              if (caDetalhe != null) '($caDetalhe)',
                            ].join(' '),
                          ),
                          _Linha(
                            'Pontos de Vida',
                            [
                              '${m.pv ?? TraducaoSrd.vazio}',
                              if (m.pvDado case final dado?) '($dado)',
                            ].join(' '),
                          ),
                          _Linha('Deslocamento', _statblock.deslocamento(m)),
                          if (atributos != null) ...[
                            divisor,
                            Row(
                              children: [
                                for (final a in Atributo.values)
                                  Expanded(
                                    child: _Atributo(
                                      sigla: a.sigla,
                                      texto: _statblock.atributo(
                                        atributos.valor(a),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          divisor,
                          if (salvaguardas.isNotEmpty)
                            _Linha('Salvaguardas', salvaguardas),
                          if (pericias.isNotEmpty) _Linha('Perícias', pericias),
                          if (m.vulnerabilidades != null)
                            _Linha(
                              'Vulnerabilidades',
                              _statblock.lista(
                                m.vulnerabilidades,
                                TraducaoSrd.defesa,
                              ),
                            ),
                          if (m.resistencias != null)
                            _Linha(
                              'Resistências',
                              _statblock.lista(
                                m.resistencias,
                                TraducaoSrd.defesa,
                              ),
                            ),
                          if (m.imunidades != null)
                            _Linha(
                              'Imunidades',
                              _statblock.lista(
                                m.imunidades,
                                TraducaoSrd.defesa,
                              ),
                            ),
                          if (m.imunidadesCondicao != null)
                            _Linha(
                              'Imune a condições',
                              _statblock.lista(
                                m.imunidadesCondicao,
                                TraducaoSrd.defesa,
                              ),
                            ),
                          if (sentidos.isNotEmpty) _Linha('Sentidos', sentidos),
                          _Linha(
                            'Idiomas',
                            _statblock.lista(m.idiomas, TraducaoSrd.idioma),
                          ),
                          _Linha('Nível de desafio', nd),
                        ],
                      ),
                    ),
                    if (m.tracos.isNotEmpty)
                      _Secao(titulo: 'Traços', acoes: m.tracos),
                    for (final (titulo, tipo) in const [
                      ('Ações', AcaoSrd.acao),
                      ('Ações bônus', AcaoSrd.bonus),
                      ('Reações', AcaoSrd.reacao),
                      ('Ações lendárias', AcaoSrd.lendaria),
                    ])
                      if (m.acoesDo(tipo) case final acoes
                          when acoes.isNotEmpty)
                        _Secao(titulo: titulo, acoes: acoes),
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
  const _Atributo({required this.sigla, required this.texto});

  final String sigla;

  // 14 (+2)
  final String texto;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final i = texto.indexOf(' ');
    final valor = i < 0 ? texto : texto.substring(0, i);
    final mod = i < 0 ? '' : texto.substring(i + 1);

    return Semantics(
      label: '$sigla $texto',
      child: ExcludeSemantics(
        child: Column(
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
              valor,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              mod,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.acoes});

  final String titulo;
  final List<AcaoSrd> acoes;

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
                          text: '${_statblock.nomeAcao(a)}. ',
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: textoLimpo(a.descricao),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_statblock.bonus(a) case final bonus
                      when bonus.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final b in bonus)
                          Etiqueta(
                            b,
                            cor: b.startsWith('Ataque')
                                ? AppColors.alerta
                                : AppColors.vida,
                          ),
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
