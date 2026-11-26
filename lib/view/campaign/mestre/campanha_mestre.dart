import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/controller/campaign/gerenciador_mesa.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/campaign/components/campanha_header.dart';
import 'package:grimorio/view/campaign/components/missao_sheet.dart';
import 'package:grimorio/view/campaign/heroi/campanha_heroi.dart';
import 'package:grimorio/view/campaign/mestre/components/codigo_convite.dart';
import 'package:grimorio/view/campaign/mestre/components/dar_item_sheet.dart';
import 'package:grimorio/view/campaign/mestre/components/dar_xp_sheet.dart';
import 'package:grimorio/view/campaign/mestre/components/mesa_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/missoes_mestre_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/mundo_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/notas_tab.dart';
import 'package:grimorio/view/campaign/mestre/components/sessoes_tab.dart';
import 'package:grimorio/view/campaign/missao/detalhes_missao.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_tabs.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

const _abas = ['Mesa', 'Missões', 'Mundo', 'Sessões', 'Notas'];

class CampanhaMestre extends StatefulWidget {
  const CampanhaMestre({
    super.key,
    required this.campanha,
    this.herois = const [],
  });

  final Campanha campanha;

  // herois da campanha
  final List<Personagem> herois;

  @override
  State<CampanhaMestre> createState() => _CampanhaMestreState();
}

class _CampanhaMestreState extends State<CampanhaMestre> {
  static const _papel = PapelCampanha.mestre;

  late final _mesa = GerenciadorMesa(
    campanha: widget.campanha,
    herois: widget.herois,
  );
  int _aba = 0;

  Campanha get _c => _mesa.campanha;
  List<Personagem> get _herois => _mesa.herois;

  void _sair() =>
      Navigator.pop<RetornoCampanha>(context, (campanha: _c, herois: _herois));

  void _aviso(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo);

  // sessao

  void _iniciarSessao() {
    var numero = 0;
    setState(() => numero = _mesa.iniciarSessao());
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
    setState(() => _mesa.encerrarSessao(resumo));
    _aviso('Sessão $numero encerrada', tipo: Snackbar.sucesso);
  }

  // xp e itens

  Future<void> _darXp(Set<String> marcados) async {
    final r = await pedirXp(context, herois: _herois, marcados: marcados);
    if (r == null || !mounted) return;
    setState(() => _mesa.darXp(r.valor, r.heroiIds));
    _aviso('+${formatarMilhar(r.valor)} XP entregue', tipo: Snackbar.sucesso);
  }

  Future<void> _darItem(Personagem heroi) async {
    final r = await pedirItem(context, herois: _herois, heroiId: heroi.id);
    final destino = r?.heroiId;
    if (r == null || destino == null || !mounted) return;
    setState(() => _mesa.darItem(r.item, destino));
    _aviso('${r.item.nome} entregue', tipo: Snackbar.sucesso);
  }

  void _desfazer(RegistroMesa r) {
    if (r.personagemId == null) return;
    setState(() => _mesa.desfazer(r));
    _aviso('Desfeito');
  }

  // missoes e mundo

  Future<void> _abrirMissao(Missao m) async {
    final r = await Navigator.of(context).push<RetornoMissao>(
      MaterialPageRoute(
        builder: (_) => DetalhesMissao(
          missao: m,
          papel: _papel,
          npcs: _c.npcs,
          herois: _herois,
          sessaoAtual: _c.sessaoAtual,
        ),
      ),
    );
    if (r == null || !mounted) return;
    setState(() => _mesa.aplicarMissao(r));
  }

  Future<void> _novaMissao() async {
    final m = await pedirMissao(context, campanhaId: _c.id);
    if (m == null || !mounted) return;
    setState(() => _mesa.adicionarMissao(m));
    _aviso('Missão criada', tipo: Snackbar.sucesso);
  }

  Future<void> _novoNpc() async {
    final npc = await pedirNpc(context, _c.id);
    if (npc == null || !mounted) return;
    setState(() => _mesa.adicionarNpc(npc));
  }

  void _revelarNpc(Npc npc, bool revelado) =>
      setState(() => _mesa.revelarNpc(npc, revelado));

  void _verComoHeroi() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CampanhaHeroi(
          campanha: _c,
          heroi: _herois.firstOrNull,
          grupo: _herois,
          modoPrevia: true,
        ),
      ),
    );
  }

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
    _ => NotasTab(texto: _c.notasMestre, onChanged: _mesa.editarNotas),
  };

  @override
  Widget build(BuildContext context) {
    return PopScope<RetornoCampanha>(
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
