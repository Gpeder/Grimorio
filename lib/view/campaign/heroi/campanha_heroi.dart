import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/gerenciador_visibilidade.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/view/campaign/components/campanha_header.dart';
import 'package:grimorio/view/campaign/heroi/components/aviso_sessao.dart';
import 'package:grimorio/view/campaign/heroi/components/diario_heroi_tab.dart';
import 'package:grimorio/view/campaign/heroi/components/grupo_tab.dart';
import 'package:grimorio/view/campaign/heroi/components/meu_heroi_card.dart';
import 'package:grimorio/view/campaign/heroi/components/missoes_heroi_tab.dart';
import 'package:grimorio/view/campaign/missao/detalhes_missao.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_tabs.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:pixelarticons/pixel.dart';

const _abas = ['Missões', 'Grupo', 'Diário'];

class CampanhaHeroi extends StatefulWidget {
  const CampanhaHeroi({
    super.key,
    required this.campanha,
    required this.heroi,
    this.grupo = const [],
    this.modoPrevia = false,
  });

  final Campanha campanha;

  // heroi do usuario
  final Personagem? heroi;

  // todos da campanha
  final List<Personagem> grupo;

  // ver como herói do mestre, so leitura
  final bool modoPrevia;

  @override
  State<CampanhaHeroi> createState() => _CampanhaHeroiState();
}

class _CampanhaHeroiState extends State<CampanhaHeroi> {
  static const _papel = PapelCampanha.heroi;

  late Personagem? _heroi = widget.heroi;
  int _aba = 0;

  Campanha get _c => widget.campanha;

  void _sair() => Navigator.pop<RetornoCampanha>(context, (
    campanha: _c,
    herois: [?_heroi],
  ));

  Future<void> _abrirFicha(Personagem heroi) async {
    final atualizado = await Navigator.of(context).push<Personagem>(
      MaterialPageRoute(builder: (_) => Ficha(personagem: heroi)),
    );
    if (atualizado == null || !mounted) return;
    setState(() => _heroi = atualizado);
  }

  void _abrirMissao(Missao m) {
    Navigator.of(context).push<RetornoMissao>(
      MaterialPageRoute(
        builder: (_) => DetalhesMissao(
          missao: m,
          papel: _papel,
          npcs: _c.npcs,
          sessaoAtual: _c.sessaoAtual,
        ),
      ),
    );
  }

  // conteudo de cada aba
  Widget _conteudoAba() => switch (_aba) {
    0 => MissoesHeroiTab(
      missoes: const GerenciadorVisibilidade().missoes(_c, _papel),
      sessaoAtual: _c.sessaoAtual,
      onAbrir: _abrirMissao,
    ),
    1 => GrupoTab(
      outros: [
        for (final h in widget.grupo)
          if (h.id != _heroi?.id) h,
      ],
    ),
    _ => DiarioHeroiTab(
      sessoes: _c.sessoes,
      npcs: const GerenciadorVisibilidade().npcs(_c, _papel),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final heroi = _heroi;
    final previa = widget.modoPrevia;

    final rolagem = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          // topo
          child: CampanhaHeader(campanha: _c, papel: _papel, semTopo: previa),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            0,
            AppSpacing.medium,
            AppSpacing.medium,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // sessao rolando
                if (_c.emSessao) ...[
                  AvisoSessao(
                    sessao: _c.sessaoAtual,
                    mestre: nomesUsuariosMock[_c.mestreId] ?? 'Mestre',
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
                if (heroi != null)
                  MeuHeroiCard(
                    heroi: heroi,
                    onAbrirFicha: previa ? null : () => _abrirFicha(heroi),
                  ),
              ],
            ),
          ),
        ),
        // abas
        FichaTabs(
          aba: _aba,
          onAba: (i) => setState(() => _aba = i),
          abas: _abas,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.large * 2,
          ),
          sliver: SliverToBoxAdapter(child: _conteudoAba()),
        ),
      ],
    );

    if (previa) {
      return Scaffold(
        body: Column(
          children: [
            const _FaixaPrevia(),
            Expanded(child: rolagem),
          ],
        ),
      );
    }

    return PopScope<RetornoCampanha>(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _sair();
      },
      child: Scaffold(body: rolagem),
    );
  }
}

class _FaixaPrevia extends StatelessWidget {
  const _FaixaPrevia();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(bottom: BorderSide(color: AppColors.alerta)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small + 2,
          ),
          child: Row(
            children: [
              const Icon(Pixel.eye, size: 18, color: AppColors.onSurface),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  'Prévia: é assim que os heróis veem',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
