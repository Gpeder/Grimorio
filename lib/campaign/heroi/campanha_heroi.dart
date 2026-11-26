import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/campaign/components/cabecalho_campanha.dart';
import 'package:grimorio/campaign/heroi/components/aba_diario_heroi.dart';
import 'package:grimorio/campaign/heroi/components/aba_grupo.dart';
import 'package:grimorio/campaign/heroi/components/aba_missoes_heroi.dart';
import 'package:grimorio/campaign/heroi/components/aviso_sessao.dart';
import 'package:grimorio/campaign/heroi/components/card_meu_heroi.dart';
import 'package:grimorio/campaign/missao/missao_detalhe.dart';
import 'package:grimorio/characters/ficha/components/ficha_abas.dart';
import 'package:grimorio/characters/ficha/ficha.dart';
import 'package:grimorio/models/campaign.dart' as dados;
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/usuario_mock.dart';
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

  final dados.Campaign campanha;

  // O herói do usuário nesta campanha.
  final Character? heroi;

  // Todos os heróis da campanha (a aba Grupo mostra os outros).
  final List<Character> grupo;

  // Aberta pelo Mestre em "Ver como herói": só leitura.
  final bool modoPrevia;

  @override
  State<CampanhaHeroi> createState() => _CampanhaHeroiState();
}

class _CampanhaHeroiState extends State<CampanhaHeroi> {
  static const _papel = dados.PapelCampanha.heroi;

  late Character? _heroi = widget.heroi;
  int _aba = 0;

  dados.Campaign get _c => widget.campanha;

  void _sair() => Navigator.pop<dados.RetornoCampanha>(context, (
    campanha: _c,
    herois: [?_heroi],
  ));

  Future<void> _abrirFicha(Character heroi) async {
    final atualizado = await Navigator.of(context).push<Character>(
      MaterialPageRoute(builder: (_) => Ficha(personagem: heroi)),
    );
    if (atualizado == null || !mounted) return;
    setState(() => _heroi = atualizado);
  }

  void _abrirMissao(dados.Missao m) {
    Navigator.of(context).push<RetornoMissao>(
      MaterialPageRoute(
        builder: (_) => MissaoDetalhe(
          missao: m,
          papel: _papel,
          npcs: _c.npcs,
          sessaoAtual: _c.sessaoAtual,
        ),
      ),
    );
  }

  Widget _conteudoAba() => switch (_aba) {
    0 => AbaMissoesHeroi(
      missoes: dados.missoesVisiveis(_c, _papel),
      sessaoAtual: _c.sessaoAtual,
      onAbrir: _abrirMissao,
    ),
    1 => AbaGrupo(
      outros: [
        for (final h in widget.grupo)
          if (h.id != _heroi?.id) h,
      ],
    ),
    _ => AbaDiarioHeroi(
      sessoes: _c.sessoes,
      npcs: dados.npcsVisiveis(_c, _papel),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final heroi = _heroi;
    final previa = widget.modoPrevia;

    final rolagem = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CabecalhoCampanha(
            campanha: _c,
            papel: _papel,
            semTopo: previa,
          ),
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
                if (_c.emSessao) ...[
                  AvisoSessao(
                    sessao: _c.sessaoAtual,
                    mestre: nomesUsuariosMock[_c.mestreId] ?? 'Mestre',
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
                if (heroi != null)
                  CardMeuHeroi(
                    heroi: heroi,
                    onAbrirFicha: previa ? null : () => _abrirFicha(heroi),
                  ),
              ],
            ),
          ),
        ),
        FichaAbas(
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

    return PopScope<dados.RetornoCampanha>(
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
