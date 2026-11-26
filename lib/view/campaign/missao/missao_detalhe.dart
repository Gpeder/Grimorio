import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/campaign/components/caixa_tracejada.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/controller/campaign/gerenciador_missoes.dart';
import 'package:grimorio/controller/campaign/gerenciador_visibilidade.dart';
import 'package:grimorio/view/campaign/components/sheet_missao.dart';
import 'package:grimorio/view/campaign/mestre/components/sheet_dar_item.dart';
import 'package:grimorio/view/campaign/missao/components/card_recompensa.dart';
import 'package:grimorio/view/campaign/missao/components/entrada_missao.dart';
import 'package:grimorio/view/campaign/missao/components/sheet_nova_entrada.dart';
import 'package:grimorio/view/characters/ficha/components/dialogo_numero.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/model/campaign.dart' as dados;
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/grimoire.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

class MissaoDetalhe extends StatefulWidget {
  const MissaoDetalhe({
    super.key,
    required this.missao,
    required this.papel,
    this.npcs = const [],
    this.herois = const [],
    this.sessaoAtual = 0,
  });

  final dados.Missao missao;
  final dados.PapelCampanha papel;
  final List<dados.Npc> npcs;
  final List<Character> herois;
  final int sessaoAtual;

  @override
  State<MissaoDetalhe> createState() => _MissaoDetalheState();
}

class _MissaoDetalheState extends State<MissaoDetalhe> {
  late final _missoes = GerenciadorMissoes(
    missao: widget.missao,
    herois: widget.herois,
  );

  static const _visibilidade = GerenciadorVisibilidade();

  dados.Missao get _m => _missoes.missao;

  bool get _mestre => widget.papel == dados.PapelCampanha.mestre;

  void _sair() => Navigator.pop<dados.RetornoMissao>(context, _missoes.retorno);

  Future<void> _acaoEntrada(dados.EntradaMissao e, AcaoEntrada acao) async {
    switch (acao) {
      case AcaoEntrada.concluir:
        setState(() => _missoes.concluirEntrada(e));
      case AcaoEntrada.apagar:
        final ok = await confirmar(
          context,
          titulo: 'Apagar entrada?',
          texto: e.texto,
          sim: 'Apagar',
        );
        if (!ok || !mounted) return;
        setState(() => _missoes.apagarEntrada(e));
    }
  }

  Future<void> _novaEntrada() async {
    final e = await pedirEntrada(context, sessao: widget.sessaoAtual);
    if (e == null || !mounted) return;
    setState(() => _missoes.adicionarEntrada(e));
  }

  Future<void> _editar() async {
    final editada = await pedirMissao(
      context,
      campanhaId: _m.campanhaId,
      missao: _m,
    );
    if (editada == null || !mounted) return;
    setState(() => _missoes.editar(editada));
  }

  void _alternarRevelada() => setState(_missoes.alternarRevelada);

  Future<void> _editarXp() async {
    final xp = await pedirNumero(
      context,
      titulo: 'Recompensa em XP',
      inicial: _m.recompensaXp,
    );
    if (xp == null || !mounted) return;
    setState(() => _missoes.definirXp(xp));
  }

  Future<void> _adicionarItem() async {
    final escolha = await pedirItem(context);
    if (escolha == null || !mounted) return;
    setState(() => _missoes.adicionarItem(escolha.item.key));
  }

  void _removerItem(String key) => setState(() => _missoes.removerItem(key));

  Future<void> _falhou() async {
    final ok = await confirmar(
      context,
      titulo: 'A missão falhou?',
      texto: 'Os heróis não recebem a recompensa.',
      sim: 'Falhou',
    );
    if (!ok || !mounted) return;
    setState(_missoes.falhar);
  }

  Future<void> _concluir() async {
    final destinos = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _DialogoConcluir(
        xp: _m.recompensaXp,
        itens: _missoes.itensRecompensa,
        herois: _missoes.herois,
      ),
    );
    if (destinos == null || !mounted) return;
    setState(() => _missoes.concluir(destinos));
    mostrarAviso(context, 'Missão concluída!', tipo: Snackbar.sucesso);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final papel = widget.papel;
    final entradas = _visibilidade.entradas(_m, papel);
    final atual = _visibilidade.objetivoAtual(_m, papel);
    final envolvidos = _visibilidade.envolvidos(_m, widget.npcs, papel);
    final rodape = _mestre && _m.ativa;

    return PopScope<dados.RetornoMissao>(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _sair();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: !rodape,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.small,
                  AppSpacing.medium,
                  AppSpacing.small,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Voltar',
                      onPressed: _sair,
                      icon: const Icon(Pixel.arrowleft),
                    ),
                    const SizedBox(width: AppSpacing.medium - 4),
                    Expanded(
                      child: Text(
                        'DIÁRIO DE MISSÕES',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.alerta,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (_mestre)
                      IconButton(
                        tooltip: 'Editar missão',
                        onPressed: _editar,
                        icon: const Icon(Pixel.pencil, color: AppColors.alerta),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.medium,
                    AppSpacing.medium,
                    AppSpacing.medium,
                    AppSpacing.large,
                  ),
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Etiqueta(_m.tipo.label, pequena: true),
                        if (_m.regiao.isNotEmpty)
                          Etiqueta(
                            _m.regiao,
                            pequena: true,
                            cor: AppColors.secondary,
                          ),
                        if (!_m.ativa)
                          Etiqueta(
                            _m.estado.label,
                            pequena: true,
                            cor: _m.estado.cor,
                          ),
                        if (_mestre)
                          Etiqueta(
                            _m.revelada ? 'Revelada aos heróis' : 'Oculta',
                            pequena: true,
                            cor: _m.revelada
                                ? AppColors.sucesso
                                : AppColors.secondary,
                            onTap: _alternarRevelada,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      _m.titulo,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_m.descricao.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        _m.descricao,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.75),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.large),
                    const RotuloSecao('Registro · mais recente primeiro'),
                    const SizedBox(height: AppSpacing.small),
                    if (entradas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.medium,
                        ),
                        child: Text(
                          'Nada registrado ainda.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    for (final e in entradas)
                      LinhaEntrada(
                        entrada: e,
                        atual: e.id == atual?.id && _m.ativa,
                        onAlternarRevelada: _mestre
                            ? () => setState(
                                () => _missoes.alternarEntradaRevelada(e),
                              )
                            : null,
                        onAcao: _mestre ? (a) => _acaoEntrada(e, a) : null,
                      ),
                    if (_mestre)
                      CaixaTracejada(
                        onTap: _novaEntrada,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Pixel.plus,
                              size: 18,
                              color: AppColors.alerta,
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Text(
                              'Nova entrada',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.alerta,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.large),
                    const RotuloSecao('Envolvidos'),
                    const SizedBox(height: AppSpacing.small),
                    if (envolvidos.isEmpty)
                      Text(
                        'Ninguém conhecido ainda.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.55),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final n in envolvidos)
                            Etiqueta(
                              n.funcao.isEmpty
                                  ? n.nome
                                  : '${n.nome} · ${n.funcao}',
                              cor: n.revelado
                                  ? AppColors.alerta
                                  : AppColors.secondary,
                            ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.large),
                    const RotuloSecao('Recompensa'),
                    const SizedBox(height: AppSpacing.small),
                    CardRecompensa(
                      missao: _m,
                      papel: papel,
                      onEditarXp: _editarXp,
                      onAdicionarItem: _adicionarItem,
                      onRemoverItem: _removerItem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: rodape
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.medium,
                    AppSpacing.small,
                    AppSpacing.medium,
                    AppSpacing.medium,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _falhou,
                          child: Text(
                            'Falhou',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.vida,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _concluir,
                          child: const Text('Concluir e distribuir'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

// Devolve, para cada item, o id do herói que recebe.
class _DialogoConcluir extends StatefulWidget {
  const _DialogoConcluir({
    required this.xp,
    required this.itens,
    required this.herois,
  });

  final int xp;
  final List<ItemCompendio> itens;
  final List<Character> herois;

  @override
  State<_DialogoConcluir> createState() => _DialogoConcluirState();
}

class _DialogoConcluirState extends State<_DialogoConcluir> {
  late final Map<String, String> _destinos = {
    if (widget.herois.isNotEmpty)
      for (final i in widget.itens) i.key: widget.herois.first.id,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final semHerois = widget.herois.isEmpty;

    return AlertDialog(
      title: const Text('Concluir missão'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (semHerois)
            const Text('Nenhum herói na campanha para receber a recompensa.')
          else if (widget.xp > 0)
            Text(
              '${formatarMilhar(widget.xp)} XP para cada herói',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.exp,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (!semHerois)
            for (final i in widget.itens) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(i.nome, style: textTheme.bodyMedium),
              DropdownButton<String>(
                isExpanded: true,
                value: _destinos[i.key],
                items: [
                  for (final h in widget.herois)
                    DropdownMenuItem(value: h.id, child: Text(h.nome)),
                ],
                onChanged: (id) {
                  if (id != null) setState(() => _destinos[i.key] = id);
                },
              ),
            ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppSpacing.small),
        TextButton(
          onPressed: () => Navigator.pop(context, _destinos),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
