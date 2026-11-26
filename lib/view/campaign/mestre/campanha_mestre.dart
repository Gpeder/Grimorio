import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/controller/campaign/gerenciador_mesa.dart';
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

  void _naMesa(void Function(GerenciadorMesa mesa) acao) => context
      .read<CampanhasProvider>()
      .naMesa(widget.campanhaId, context.read<PersonagensProvider>(), acao);

  void _sair() => context.pop();

  void _aviso(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo);

  // sessao

  void _iniciarSessao() {
    var numero = 0;
    _naMesa((mesa) => numero = mesa.iniciarSessao());
    _aviso('Sessão $numero iniciada', tipo: Snackbar.sucesso);
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
    _naMesa((mesa) => mesa.encerrarSessao(resumo));
    _aviso('Sessão $numero encerrada', tipo: Snackbar.sucesso);
  }

  // xp e itens

  Future<void> _darXp(Set<String> marcados) async {
    final r = await pedirXp(context, herois: _herois, marcados: marcados);
    if (r == null || !mounted) return;
    _naMesa((mesa) => mesa.darXp(r.valor, r.heroiIds));
    _aviso('+${formatarMilhar(r.valor)} XP entregue', tipo: Snackbar.sucesso);
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
    _naMesa((mesa) => mesa.darItem(r.item, destino));
    _aviso('${r.item.nome} entregue', tipo: Snackbar.sucesso);
  }

  void _desfazer(RegistroMesa r) {
    if (r.personagemId == null) return;
    _naMesa((mesa) => mesa.desfazer(r));
    _aviso('Desfeito');
  }

  // missoes e mundo

  void _abrirMissao(Missao m) => context.pushNamed(
    Rotas.nomeMissao,
    pathParameters: {Rotas.campanhaId: widget.campanhaId, Rotas.missaoId: m.id},
  );

  Future<void> _novaMissao() async {
    final m = await pedirMissao(context, campanhaId: _c.id);
    if (m == null || !mounted) return;
    _naMesa((mesa) => mesa.adicionarMissao(m));
    _aviso('Missão criada', tipo: Snackbar.sucesso);
  }

  Future<void> _novoNpc() async {
    final npc = await pedirNpc(context, _c.id);
    if (npc == null || !mounted) return;
    _naMesa((mesa) => mesa.adicionarNpc(npc));
  }

  void _revelarNpc(Npc npc, bool revelado) =>
      _naMesa((mesa) => mesa.revelarNpc(npc, revelado));

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
      onChanged: (t) => _naMesa((mesa) => mesa.editarNotas(t)),
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
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              // topo
              child: CampanhaHeader(
                campanha: _c,
                papel: _papel,
                trailing: _c.codigoConvite.isEmpty
                    ? null
                    : CodigoConvite(codigo: _c.codigoConvite),
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
