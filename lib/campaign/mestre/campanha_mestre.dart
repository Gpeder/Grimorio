import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/campaign/components/cabecalho_campanha.dart';
import 'package:grimorio/campaign/components/formatos.dart';
import 'package:grimorio/campaign/components/sheet_missao.dart';
import 'package:grimorio/campaign/heroi/campanha_heroi.dart';
import 'package:grimorio/campaign/mestre/components/aba_mesa.dart';
import 'package:grimorio/campaign/mestre/components/aba_missoes_mestre.dart';
import 'package:grimorio/campaign/mestre/components/aba_mundo.dart';
import 'package:grimorio/campaign/mestre/components/aba_notas.dart';
import 'package:grimorio/campaign/mestre/components/aba_sessoes.dart';
import 'package:grimorio/campaign/mestre/components/codigo_convite.dart';
import 'package:grimorio/campaign/mestre/components/sheet_dar_item.dart';
import 'package:grimorio/campaign/mestre/components/sheet_dar_xp.dart';
import 'package:grimorio/campaign/missao/missao_detalhe.dart';
import 'package:grimorio/characters/ficha/components/ficha_abas.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/models/campaign.dart' as dados;
import 'package:grimorio/models/character.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

const _abas = ['Mesa', 'Missões', 'Mundo', 'Sessões', 'Notas'];

class CampanhaMestre extends StatefulWidget {
  const CampanhaMestre({
    super.key,
    required this.campanha,
    this.herois = const [],
  });

  final dados.Campaign campanha;

  // Heróis desta campanha.
  final List<Character> herois;

  @override
  State<CampanhaMestre> createState() => _CampanhaMestreState();
}

class _CampanhaMestreState extends State<CampanhaMestre> {
  static const _papel = dados.PapelCampanha.mestre;

  late dados.Campaign _c = widget.campanha;
  late List<Character> _herois = [...widget.herois];
  int _aba = 0;

  void _sair() => Navigator.pop<dados.RetornoCampanha>(context, (
    campanha: _c,
    herois: _herois,
  ));

  void _aviso(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo);

  dados.RegistroMesa _registro(
    dados.TipoRegistro tipo,
    String texto, {
    String? personagemId,
    int? valor,
    String? itemKey,
  }) => dados.RegistroMesa(
    id: novoId('registro'),
    campanhaId: _c.id,
    tipo: tipo,
    texto: texto,
    personagemId: personagemId,
    valor: valor,
    itemKey: itemKey,
    criadoEm: DateTime.now(),
  );

  void _trocarHeroi(String id, Character Function(Character h) f) {
    _herois = [for (final h in _herois) h.id == id ? f(h) : h];
  }

  // Sessão

  void _iniciarSessao() {
    final numero = _c.sessaoAtual + 1;
    setState(() {
      _c = _c.copyWith(emSessao: true, sessaoAtual: numero).registrar([
        _registro(dados.TipoRegistro.sessao, 'Sessão $numero iniciada'),
      ]);
    });
    _aviso('Sessão $numero iniciada', tipo: Snackbar.sucesso);
  }

  // XP dado desde o último registro de sessão (o "iniciada").
  int get _xpDaSessao {
    var total = 0;
    for (final r in _c.registros) {
      if (r.tipo == dados.TipoRegistro.sessao) break;
      if (r.tipo == dados.TipoRegistro.xp) total += r.valor ?? 0;
    }
    return total;
  }

  Future<void> _encerrarSessao() async {
    final numero = _c.sessaoAtual;
    final resumo = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _SheetEncerrar(numero: numero),
    );
    if (resumo == null || !mounted) return;
    final sessao = dados.Sessao(
      id: novoId('sessao'),
      campanhaId: _c.id,
      numero: numero,
      data: DateTime.now(),
      resumo: resumo,
      xpTotal: _xpDaSessao,
    );
    setState(() {
      _c = _c
          .copyWith(emSessao: false, sessoes: [..._c.sessoes, sessao])
          .registrar([
            _registro(dados.TipoRegistro.sessao, 'Sessão $numero encerrada'),
          ]);
    });
    _aviso('Sessão $numero encerrada', tipo: Snackbar.sucesso);
  }

  // XP e itens

  Future<void> _darXp(Set<String> marcados) async {
    final r = await pedirXp(context, herois: _herois, marcados: marcados);
    if (r == null || !mounted) return;
    final novos = <dados.RegistroMesa>[];
    setState(() {
      for (final id in r.heroiIds) {
        _trocarHeroi(id, (h) => h.ganharXp(r.valor));
        final nome = _herois.firstWhere((h) => h.id == id).nome;
        novos.add(
          _registro(
            dados.TipoRegistro.xp,
            '+${formatarMilhar(r.valor)} XP para $nome',
            personagemId: id,
            valor: r.valor,
          ),
        );
      }
      _c = _c.registrar(novos);
    });
    _aviso('+${formatarMilhar(r.valor)} XP entregue', tipo: Snackbar.sucesso);
  }

  Future<void> _darItem(Character heroi) async {
    final r = await pedirItem(context, herois: _herois, heroiId: heroi.id);
    final destino = r?.heroiId;
    if (r == null || destino == null || !mounted) return;
    setState(() {
      _trocarHeroi(
        destino,
        (h) => h.receberItem(dados.itemDoCompendio(r.item)),
      );
      final nome = _herois.firstWhere((h) => h.id == destino).nome;
      _c = _c.registrar([
        _registro(
          dados.TipoRegistro.item,
          '${r.item.nome} para $nome',
          personagemId: destino,
          itemKey: r.item.key,
        ),
      ]);
    });
    _aviso('${r.item.nome} entregue', tipo: Snackbar.sucesso);
  }

  void _desfazer(dados.RegistroMesa r) {
    final id = r.personagemId;
    if (id == null) return;
    setState(() {
      switch (r.tipo) {
        case dados.TipoRegistro.xp:
          _trocarHeroi(id, (h) => h.ganharXp(-(r.valor ?? 0)));
        case dados.TipoRegistro.item:
          _trocarHeroi(id, (h) => h.removerUmaUnidade(r.itemKey ?? ''));
        default:
          return;
      }
      _c = _c.copyWith(
        registros: [
          for (final x in _c.registros)
            if (x.id != r.id) x,
        ],
      );
    });
    _aviso('Desfeito');
  }

  // Missões e mundo

  Future<void> _abrirMissao(dados.Missao m) async {
    final r = await Navigator.of(context).push<RetornoMissao>(
      MaterialPageRoute(
        builder: (_) => MissaoDetalhe(
          missao: m,
          papel: _papel,
          npcs: _c.npcs,
          herois: _herois,
          sessaoAtual: _c.sessaoAtual,
        ),
      ),
    );
    if (r == null || !mounted) return;
    setState(() {
      _c = _c.trocarMissao(r.missao).registrar(r.registros);
      _herois = r.herois;
    });
  }

  Future<void> _novaMissao() async {
    final m = await pedirMissao(context, campanhaId: _c.id);
    if (m == null || !mounted) return;
    setState(() {
      _c = _c.copyWith(missoes: [..._c.missoes, m]);
    });
    _aviso('Missão criada', tipo: Snackbar.sucesso);
  }

  Future<void> _novoNpc() async {
    final npc = await pedirNpc(context, _c.id);
    if (npc == null || !mounted) return;
    setState(() => _c = _c.copyWith(npcs: [..._c.npcs, npc]));
  }

  void _revelarNpc(dados.Npc npc, bool revelado) => setState(() {
    _c = _c.copyWith(
      npcs: [
        for (final n in _c.npcs)
          n.id == npc.id ? n.copyWith(revelado: revelado) : n,
      ],
    );
  });

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

  Widget _conteudoAba() => switch (_aba) {
    0 => AbaMesa(
      campanha: _c,
      herois: _herois,
      onXp: (h) => _darXp({h.id}),
      onXpTodos: () => _darXp({for (final h in _herois) h.id}),
      onItem: _darItem,
      onAbrirMissao: _abrirMissao,
      onDesfazer: _desfazer,
    ),
    1 => AbaMissoesMestre(
      missoes: _c.missoes,
      sessaoAtual: _c.sessaoAtual,
      onAbrir: _abrirMissao,
      onNova: _novaMissao,
    ),
    2 => AbaMundo(npcs: _c.npcs, onRevelar: _revelarNpc, onNovo: _novoNpc),
    3 => AbaSessoes(sessoes: _c.sessoes),
    _ => AbaNotas(
      texto: _c.notasMestre,
      onChanged: (t) => _c = _c.copyWith(notasMestre: t),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return PopScope<dados.RetornoCampanha>(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _sair();
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CabecalhoCampanha(
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
        ),
      ),
    );
  }
}

class _SheetEncerrar extends StatefulWidget {
  const _SheetEncerrar({required this.numero});

  final int numero;

  @override
  State<_SheetEncerrar> createState() => _SheetEncerrarState();
}

class _SheetEncerrarState extends State<_SheetEncerrar> {
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
