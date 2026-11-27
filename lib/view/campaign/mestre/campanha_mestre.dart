import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/model/personagem.dart';

import 'package:grimorio/view/campaign/components/campanha_header.dart';
import 'package:grimorio/view/campaign/components/missao_sheet.dart';
import 'package:grimorio/view/campaign/mestre/components/codigo_convite.dart';
import 'package:grimorio/view/campaign/mestre/components/dar_item_sheet.dart';
import 'package:grimorio/view/campaign/mestre/components/dar_xp_sheet.dart';
import 'package:grimorio/view/campaign/mestre/components/mesa_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/missoes_mestre_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/mundo_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/notas_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/sessoes_tab.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_tabs.dart';
import 'package:grimorio/view/characters/ficha/components/numero_dialog.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/widgets/estado_nao_encontrado.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

const _abas = ['Mesa', 'Missões', 'Mundo', 'Sessões', 'Notas'];

class CampanhaMestre extends StatefulWidget {
  const CampanhaMestre({super.key, required this.campanhaId});

  final String campanhaId;

  @override
  State<CampanhaMestre> createState() => _CampanhaMestreState();
}

class _CampanhaMestreState extends State<CampanhaMestre> {
  static const _papel = PapelCampanha.mestre;

  int _aba = 0;

  // dados sempre do provider
  Campanha get _c =>
      context.read<CampanhasProvider>().porId(widget.campanhaId)!;
  List<Personagem> get _herois =>
      context.read<PersonagensProvider>().daCampanha(_c);

  CampanhasProvider get _campanhas => context.read<CampanhasProvider>();

  // tela aberta ouve o banco; sai da tela, para de ouvir
  Future<void> Function()? _pararEscuta;

  @override
  void initState() {
    super.initState();
    _pararEscuta = _campanhas.ouvir(widget.campanhaId);
    // dados frescos (registros e notas so vem para o mestre)
    WidgetsBinding.instance.addPostFrameCallback((_) => _recarregar());
  }

  @override
  void dispose() {
    _pararEscuta?.call();
    super.dispose();
  }

  Future<void> _recarregar() => _acao(
    'recarregar campanha',
    () => _campanhas.recarregar(widget.campanhaId),
  );

  void _sair() => context.pop();

  void _aviso(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo);

  // roda no banco; se falhar mostra o erro amigavel
  Future<bool> _acao(String onde, Future<void> Function() acao) async {
    try {
      await acao();
      return true;
    } catch (e, stack) {
      if (mounted) mostrarErro(context, e, stack: stack, onde: onde);
      return false;
    }
  }

  // sessao

  Future<void> _iniciarSessao() async {
    var numero = 0;
    final ok = await _acao(
      'iniciar sessao',
      () async => numero = await _campanhas.iniciarSessao(widget.campanhaId),
    );
    if (ok && mounted) {
      _aviso('Sessão $numero iniciada', tipo: Snackbar.sucesso);
    }
  }

  Future<void> _encerrarSessao() async {
    final numero = _c.sessaoAtual;
    final resumo = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _EncerrarSheet(numero: numero),
    );
    if (resumo == null || !mounted) return;
    final ok = await _acao(
      'encerrar sessao',
      () => _campanhas.encerrarSessao(widget.campanhaId, resumo),
    );
    if (ok && mounted) {
      _aviso('Sessão $numero encerrada', tipo: Snackbar.sucesso);
    }
  }

  // xp e itens: sempre pela rpc

  Future<void> _darXp(Set<String> marcados) async {
    final r = await pedirXp(context, herois: _herois, marcados: marcados);
    if (r == null || !mounted) return;
    final ok = await _acao(
      'dar xp',
      () => _campanhas.darXp(widget.campanhaId, r.heroiIds, r.valor),
    );
    if (ok && mounted) {
      _aviso('+${formatarMilhar(r.valor)} XP entregue', tipo: Snackbar.sucesso);
    }
  }

  Future<void> _darItem(Personagem heroi) async {
    final r = await pedirItem(
      context,
      itens: itensMock,
      herois: _herois,
      heroiId: heroi.id,
    );
    final destino = r?.heroiId;
    if (r == null || destino == null || !mounted) return;
    final ok = await _acao(
      'dar item',
      () => _campanhas.darItem(widget.campanhaId, destino, r.item),
    );
    if (ok && mounted) {
      _aviso('${r.item.nome} entregue', tipo: Snackbar.sucesso);
    }
  }

  Future<void> _desfazer(RegistroMesa r) async {
    if (r.personagemId == null) return;
    final ok = await _acao(
      'desfazer',
      () => _campanhas.desfazer(widget.campanhaId, r),
    );
    if (ok && mounted) _aviso('Desfeito');
  }

  // grupo e convite

  Future<void> _removerHeroi(Personagem heroi) async {
    final ok = await confirmar(
      context,
      titulo: 'Remover ${heroi.nome}?',
      texto: 'O herói sai da campanha e pode entrar de novo com o código.',
      sim: 'Remover',
    );
    if (!ok || !mounted) return;
    final removido = await _acao(
      'remover heroi',
      () => _campanhas.removerHeroi(widget.campanhaId, heroi.id),
    );
    if (removido && mounted) _aviso('${heroi.nome} saiu da campanha');
  }

  Future<void> _novoCodigo() async {
    final ok = await confirmar(
      context,
      titulo: 'Gerar novo código?',
      texto: 'O código atual para de funcionar.',
      sim: 'Gerar',
    );
    if (!ok || !mounted) return;
    var codigo = '';
    final gerou = await _acao(
      'novo codigo',
      () async => codigo = await _campanhas.novoCodigo(widget.campanhaId),
    );
    if (gerou && mounted) {
      _aviso('Novo código: $codigo', tipo: Snackbar.sucesso);
    }
  }

  // missoes e mundo

  void _abrirMissao(Missao m) => context.pushNamed(
    Rotas.nomeMissao,
    pathParameters: {Rotas.campanhaId: widget.campanhaId, Rotas.missaoId: m.id},
  );

  Future<void> _novaMissao() async {
    final m = await pedirMissao(context, campanhaId: _c.id);
    if (m == null || !mounted) return;
    final ok = await _acao('nova missao', () => _campanhas.criarMissao(m));
    if (ok && mounted) _aviso('Missão criada', tipo: Snackbar.sucesso);
  }

  Future<void> _novoNpc() async {
    final npc = await pedirNpc(context, _c.id);
    if (npc == null || !mounted) return;
    await _acao('novo npc', () => _campanhas.criarNpc(npc));
  }

  Future<void> _revelarNpc(Npc npc, bool revelado) => _acao(
    'revelar npc',
    () => _campanhas.editarNpc(npc, npc.copyWith(revelado: revelado)),
  );

  void _verComoHeroi() => context.pushNamed(
    Rotas.nomePrevia,
    pathParameters: {Rotas.campanhaId: widget.campanhaId},
  );

  // conteudo de cada aba
  Widget _conteudoAba() => switch (_aba) {
    0 => MesaTab(
      campanha: _c,
      herois: _herois,
      onXp: (h) => _darXp({h.id}),
      onXpTodos: () => _darXp({for (final h in _herois) h.id}),
      onItem: _darItem,
      onAbrirMissao: _abrirMissao,
      onDesfazer: _desfazer,
      onRemover: _removerHeroi,
    ),
    1 => MissoesMestreTab(
      missoes: _c.missoes,
      sessaoAtual: _c.sessaoAtual,
      onAbrir: _abrirMissao,
      onNova: _novaMissao,
    ),
    2 => MundoTab(npcs: _c.npcs, onRevelar: _revelarNpc, onNovo: _novoNpc),
    3 => SessoesTab(sessoes: _c.sessoes),
    _ => NotasTab(
      texto: _c.notasMestre,
      onChanged: (t) => _campanhas.editarNotas(widget.campanhaId, t),
    ),
  };

  @override
  Widget build(BuildContext context) {
    // reconstroi quando campanha ou herois mudam
    final c = context.watch<CampanhasProvider>().porId(widget.campanhaId);
    context.watch<PersonagensProvider>();
    if (c == null) return const EstadoNaoEncontrado();

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _sair();
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _recarregar,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                // topo
                child: CampanhaHeader(
                  campanha: _c,
                  papel: _papel,
                  trailing: _c.codigoConvite.isEmpty
                      ? null
                      : CodigoConvite(
                          codigo: _c.codigoConvite,
                          onNovo: _novoCodigo,
                        ),
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
                  child: Row(
                    children: [
                      Expanded(
                        // iniciar ou encerrar sessao
                        child: _c.emSessao
                            ? ElevatedButton.icon(
                                onPressed: _encerrarSessao,
                                icon: const Icon(Pixel.stop),
                                label: const Text('Encerrar sessão'),
                              )
                            : ElevatedButton.icon(
                                onPressed: _iniciarSessao,
                                icon: const Icon(Pixel.play),
                                label: Text(
                                  'Iniciar sessão ${_c.sessaoAtual + 1}',
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _verComoHeroi,
                          icon: const Icon(Pixel.eye),
                          label: const Text('Ver como herói'),
                        ),
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
          ),
        ),
      ),
    );
  }
}

class _EncerrarSheet extends StatefulWidget {
  const _EncerrarSheet({required this.numero});

  final int numero;

  @override
  State<_EncerrarSheet> createState() => _EncerrarSheetState();
}

class _EncerrarSheetState extends State<_EncerrarSheet> {
  final _resumo = TextEditingController();

  @override
  void dispose() {
    _resumo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium,
          0,
          AppSpacing.medium,
          AppSpacing.medium + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloSecao('Encerrar sessão ${widget.numero}'),
            TextField(
              key: const ValueKey('sessao-resumo'),
              controller: _resumo,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Resumo',
                hintText: 'O que o grupo fez hoje?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _resumo.text.trim()),
              child: const Text('Encerrar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}
