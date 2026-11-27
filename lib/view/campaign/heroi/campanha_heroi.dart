import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/controller/campaign/gerenciador_visibilidade.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/campaign/components/campanha_header.dart';
import 'package:grimorio/view/campaign/heroi/components/aviso_sessao.dart';
import 'package:grimorio/view/campaign/heroi/components/diario_heroi_tab.dart';
import 'package:grimorio/view/campaign/heroi/components/grupo_tab.dart';
import 'package:grimorio/view/campaign/heroi/components/meu_heroi_card.dart';
import 'package:grimorio/view/campaign/heroi/components/missoes_heroi_tab.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_tabs.dart';
import 'package:grimorio/widgets/estado_nao_encontrado.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

const _abas = ['Missões', 'Grupo', 'Diário'];

class CampanhaHeroi extends StatefulWidget {
  const CampanhaHeroi({
    super.key,
    required this.campanhaId,
    this.modoPrevia = false,
  });

  final String campanhaId;

  // ver como herói do mestre, so leitura
  final bool modoPrevia;

  @override
  State<CampanhaHeroi> createState() => _CampanhaHeroiState();
}

class _CampanhaHeroiState extends State<CampanhaHeroi> {
  static const _papel = PapelCampanha.heroi;

  int _aba = 0;

  static const _campanhas = GerenciadorCampanhas();

  Campanha get _c =>
      context.read<CampanhasProvider>().porId(widget.campanhaId)!;

  // todos da campanha
  List<Personagem> get _grupo =>
      context.read<PersonagensProvider>().daCampanha(_c);

  // na previa o mestre ve o primeiro heroi
  Personagem? get _heroi => widget.modoPrevia
      ? _grupo.firstOrNull
      : _campanhas.heroiDoUsuario(
          _grupo,
          context.read<UsuarioProvider>().usuario.id,
        );

  // tela aberta ouve o banco; a previa do mestre nao precisa
  Future<void> Function()? _pararEscuta;

  @override
  void initState() {
    super.initState();
    if (!widget.modoPrevia) {
      _pararEscuta = context.read<CampanhasProvider>().ouvir(widget.campanhaId);
      WidgetsBinding.instance.addPostFrameCallback((_) => _recarregar());
    }
  }

  @override
  void dispose() {
    _pararEscuta?.call();
    super.dispose();
  }

  // o que o mestre esconder some aqui so na recarga (a rls corta o evento)
  Future<void> _recarregar() async {
    try {
      await context.read<CampanhasProvider>().recarregar(widget.campanhaId);
    } catch (e, stack) {
      if (mounted) {
        mostrarErro(context, e, stack: stack, onde: 'recarregar campanha');
      }
    }
  }

  void _sair() => context.pop();

  void _abrirFicha(Personagem heroi) => context.pushNamed(
    Rotas.nomeFicha,
    pathParameters: {Rotas.heroiId: heroi.id},
  );

  // na previa a missao abre como heroi
  void _abrirMissao(Missao m) => context.pushNamed(
    widget.modoPrevia ? Rotas.nomeMissaoPrevia : Rotas.nomeMissao,
    pathParameters: {Rotas.campanhaId: widget.campanhaId, Rotas.missaoId: m.id},
  );

  // conteudo de cada aba
  Widget _conteudoAba() => switch (_aba) {
    0 => MissoesHeroiTab(
      missoes: const GerenciadorVisibilidade().missoes(_c, _papel),
      sessaoAtual: _c.sessaoAtual,
      onAbrir: _abrirMissao,
    ),
    1 => GrupoTab(
      outros: [
        for (final h in _grupo)
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
    // reconstroi quando campanha ou herois mudam
    final campanhas = context.watch<CampanhasProvider>();
    final c = campanhas.porId(widget.campanhaId);
    context.watch<PersonagensProvider>();
    if (c == null) return const EstadoNaoEncontrado();
    final heroi = _heroi;
    final previa = widget.modoPrevia;

    final rolagem = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                    mestre: campanhas.nomeDe(_c.mestreId) ?? 'Mestre',
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

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _sair();
      },
      child: Scaffold(
        body: RefreshIndicator(onRefresh: _recarregar, child: rolagem),
      ),
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
                onPressed: () => context.pop(),
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
