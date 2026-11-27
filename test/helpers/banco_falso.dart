import 'package:flutter/foundation.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/controller/campaign/gerenciador_mesa.dart';
import 'package:grimorio/controller/campaign/gerenciador_missoes.dart';
import 'package:grimorio/controller/characters/gerenciador_inventario.dart';
import 'package:grimorio/controller/characters/gerenciador_personagens.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';
import 'package:grimorio/service/supabase/campanha_service.dart';
import 'package:grimorio/service/supabase/mesa_service.dart';
import 'package:grimorio/service/supabase/missao_service.dart';
import 'package:grimorio/service/supabase/npc_service.dart';
import 'package:grimorio/service/supabase/personagem_service.dart';
import 'package:grimorio/service/supabase/realtime_service.dart';
import 'package:grimorio/service/supabase/servicos_banco.dart';

import '../fixtures/campanha_mock.dart';
import '../fixtures/personagem_mock.dart';
import '../fixtures/usuario_mock.dart';

// banco em memoria com os dados do mock; tudo responde na hora
class BancoFalso {
  BancoFalso({
    List<Campanha>? campanhas,
    List<Personagem>? personagens,
    String Function()? usuario,
  }) : campanhas = [...campanhas ?? campanhasFalsas()],
       personagens = [
         for (final p in personagens ?? todosPersonagensMock)
           p.copyWith(notas: const []),
       ],
       _usuario = usuario ?? (() => usuarioMock.id) {
    for (final p in personagens ?? todosPersonagensMock) {
      if (p.notas.isNotEmpty) notas[p.id] = [...p.notas];
    }
  }

  List<Campanha> campanhas;
  List<Personagem> personagens;
  final notas = <String, List<Nota>>{};
  final String Function() _usuario;

  // contador de chamadas por metodo ('personagens.atualizar', 'mesa.darXp'...)
  final chamadas = <String, int>{};

  // cada atualizar recebido: (id, campos)
  final atualizacoes = <(String, Map<String, dynamic>)>[];

  // a proxima chamada falha com esse erro
  Object? proximoErro;

  int _sequencia = 0;

  String get usuarioId => _usuario();
  int vezes(String metodo) => chamadas[metodo] ?? 0;
  String novoId(String prefixo) => '$prefixo-${_sequencia++}';

  late final realtime = RealtimeServiceFalso();

  late final servicos = ServicosBanco(
    personagens: PersonagemServiceFalso(this),
    campanhas: CampanhaServiceFalso(this),
    missoes: MissaoServiceFalso(this),
    npcs: NpcServiceFalso(this),
    mesa: MesaServiceFalso(this),
    realtime: realtime,
  );

  // conta a chamada e lanca o erro programado
  void passo(String metodo) {
    chamadas[metodo] = vezes(metodo) + 1;
    final erro = proximoErro;
    if (erro == null) return;
    proximoErro = null;
    // igual ao service de verdade: nada de PostgrestException vaza
    throw BancoErro.de(erro);
  }

  Campanha? campanha(String id) =>
      campanhas.where((c) => c.id == id).firstOrNull;

  Personagem? personagem(String id) =>
      personagens.where((p) => p.id == id).firstOrNull;

  List<Personagem> heroisDe(String campanhaId) => [
    for (final p in personagens)
      if (p.campanhaId == campanhaId) p,
  ];

  // como a rls: mestre ou dono de heroi na campanha
  bool enxerga(Campanha c) =>
      c.mestreId == usuarioId ||
      personagens.any((p) => p.campanhaId == c.id && p.donoId == usuarioId);

  void trocarCampanha(Campanha c) =>
      campanhas = const GerenciadorCampanhas().trocar(campanhas, c);

  void trocarHerois(List<Personagem> alterados) => personagens =
      const GerenciadorPersonagens().trocarTodos(personagens, alterados);

  // missao e a campanha dela
  (Campanha, Missao) missao(String id) {
    for (final c in campanhas) {
      for (final m in c.missoes) {
        if (m.id == id) return (c, m);
      }
    }
    throw const BancoErro(TipoErroBanco.naoEncontrado);
  }
}

// campanhas do mock com codigo no formato do banco
List<Campanha> campanhasFalsas() => [
  for (final c in campanhasMock)
    c.copyWith(
      codigoConvite: switch (c.codigoConvite) {
        'VALF-42' => 'VALF-0042',
        'TRON-17' => 'TRON-0017',
        final outro => outro,
      },
    ),
];

Future<T> _ja<T>(T valor) => SynchronousFuture(valor);

class PersonagemServiceFalso implements PersonagemService {
  PersonagemServiceFalso(this.b);

  final BancoFalso b;

  @override
  Future<List<Personagem>> visiveis() {
    b.passo('personagens.visiveis');
    final minhas = {
      for (final c in b.campanhas)
        if (b.enxerga(c)) c.id,
    };
    return _ja([
      for (final p in b.personagens)
        if (p.donoId == b.usuarioId || minhas.contains(p.campanhaId)) p,
    ]);
  }

  @override
  Future<List<Personagem>> meus(String usuarioId) {
    b.passo('personagens.meus');
    return _ja([
      for (final p in b.personagens)
        if (p.donoId == usuarioId) p,
    ]);
  }

  @override
  Future<List<Personagem>> daCampanha(String campanhaId) {
    b.passo('personagens.daCampanha');
    return _ja(b.heroisDe(campanhaId));
  }

  @override
  Future<Personagem> criar(Personagem p) {
    b.passo('personagens.criar');
    final novo = Personagem.fromJson({
      ...p.toJson(),
      'id': b.novoId('heroi'),
      'dono_id': b.usuarioId,
      'campanha_id': null,
      'ativo': false,
      'notas': const [],
    });
    b.personagens = [...b.personagens, novo];
    return _ja(novo);
  }

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) {
    b.passo('personagens.atualizar');
    b.atualizacoes.add((id, campos));
    final p = b.personagem(id);
    if (p != null) {
      b.trocarHerois([
        Personagem.fromJson({...p.toJson(), ...campos}),
      ]);
    }
    return _ja(null);
  }

  @override
  Future<void> apagar(String id) {
    b.passo('personagens.apagar');
    b.personagens = [
      for (final p in b.personagens)
        if (p.id != id) p,
    ];
    return _ja(null);
  }

  @override
  Future<void> ativar(String id) {
    b.passo('personagens.ativar');
    b.personagens = [
      for (final p in b.personagens)
        p.donoId == b.usuarioId ? p.copyWith(ativo: p.id == id) : p,
    ];
    return _ja(null);
  }

  @override
  Future<Map<String, List<Nota>>> notas() {
    b.passo('personagens.notas');
    return _ja({
      for (final e in b.notas.entries) e.key: [...e.value],
    });
  }

  @override
  Future<Nota> criarNota(String personagemId, Nota nota) {
    b.passo('personagens.criarNota');
    final nova = Nota.fixa(
      id: b.novoId('nota'),
      titulo: nota.titulo,
      texto: nota.texto,
      dataMs: nota.dataMs,
    );
    b.notas[personagemId] = [nova, ...?b.notas[personagemId]];
    return _ja(nova);
  }

  @override
  Future<void> apagarNota(String id) {
    b.passo('personagens.apagarNota');
    for (final e in b.notas.entries) {
      e.value.removeWhere((n) => n.id == id);
    }
    return _ja(null);
  }
}

class CampanhaServiceFalso implements CampanhaService {
  CampanhaServiceFalso(this.b);

  final BancoFalso b;

  @override
  Future<List<Campanha>> minhas() {
    b.passo('campanhas.minhas');
    return _ja([
      for (final c in b.campanhas)
        if (b.enxerga(c)) c,
    ]);
  }

  @override
  Future<Campanha> buscar(String id, {required bool mestre}) {
    b.passo('campanhas.buscar');
    final c = b.campanha(id);
    if (c == null || !b.enxerga(c)) {
      throw const BancoErro(TipoErroBanco.naoEncontrado);
    }
    return _ja(mestre ? c : c.copyWith(registros: const [], notasMestre: ''));
  }

  @override
  Future<Campanha> criar({required String nome, required String capitulo}) {
    b.passo('campanhas.criar');
    final letras = nome
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z]'), '')
        .padRight(4, 'X')
        .substring(0, 4);
    final nova = Campanha(
      id: b.novoId('campanha'),
      nome: nome,
      capitulo: capitulo,
      mestreId: b.usuarioId,
      codigoConvite: '$letras-${1000 + b.campanhas.length}',
    );
    b.campanhas = [...b.campanhas, nova];
    return _ja(nova);
  }

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) {
    b.passo('campanhas.atualizar');
    final c = b.campanha(id);
    if (c != null) {
      b.trocarCampanha(Campanha.fromJson({...c.toJson(), ...campos}));
    }
    return _ja(null);
  }

  @override
  Future<void> apagar(String id) {
    b.passo('campanhas.apagar');
    b.campanhas = [
      for (final c in b.campanhas)
        if (c.id != id) c,
    ];
    return _ja(null);
  }

  @override
  Future<void> editarNotas(String campanhaId, String texto) {
    b.passo('campanhas.editarNotas');
    final c = b.campanha(campanhaId);
    if (c != null) b.trocarCampanha(c.copyWith(notasMestre: texto));
    return _ja(null);
  }
}

class MissaoServiceFalso implements MissaoService {
  MissaoServiceFalso(this.b);

  final BancoFalso b;

  static const _g = GerenciadorCampanhas();

  @override
  Future<Missao> criar(Missao m) {
    b.passo('missoes.criar');
    final nova = m.copyWith(id: b.novoId('missao'));
    final c = b.campanha(m.campanhaId);
    if (c != null) b.trocarCampanha(_g.trocarMissao(c, nova));
    return _ja(nova);
  }

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) {
    b.passo('missoes.atualizar');
    final (c, m) = b.missao(id);
    b.trocarCampanha(
      _g.trocarMissao(c, Missao.fromJson({...m.toJson(), ...campos})),
    );
    return _ja(null);
  }

  @override
  Future<void> apagar(String id) {
    b.passo('missoes.apagar');
    final (c, _) = b.missao(id);
    b.trocarCampanha(_g.tirarMissao(c, id));
    return _ja(null);
  }

  @override
  Future<EntradaMissao> criarEntrada(String missaoId, EntradaMissao e) {
    b.passo('missoes.criarEntrada');
    final (c, _) = b.missao(missaoId);
    final nova = e.copyWith(id: b.novoId('entrada'));
    b.trocarCampanha(_g.trocarEntrada(c, missaoId, nova));
    return _ja(nova);
  }

  (Campanha, Missao, EntradaMissao) _entrada(String id) {
    for (final c in b.campanhas) {
      for (final m in c.missoes) {
        for (final e in m.entradas) {
          if (e.id == id) return (c, m, e);
        }
      }
    }
    throw const BancoErro(TipoErroBanco.naoEncontrado);
  }

  @override
  Future<void> atualizarEntrada(String id, Map<String, dynamic> campos) {
    b.passo('missoes.atualizarEntrada');
    final (c, m, e) = _entrada(id);
    b.trocarCampanha(
      _g.trocarEntrada(
        c,
        m.id,
        EntradaMissao.fromJson({...e.toJson(), ...campos}),
      ),
    );
    return _ja(null);
  }

  @override
  Future<void> apagarEntrada(String id) {
    b.passo('missoes.apagarEntrada');
    final (c, m, _) = _entrada(id);
    b.trocarCampanha(_g.tirarEntrada(c, m.id, id));
    return _ja(null);
  }
}

class NpcServiceFalso implements NpcService {
  NpcServiceFalso(this.b);

  final BancoFalso b;

  static const _g = GerenciadorCampanhas();

  @override
  Future<Npc> criar(Npc npc) {
    b.passo('npcs.criar');
    final novo = npc.copyWith(id: b.novoId('npc'));
    final c = b.campanha(npc.campanhaId);
    if (c != null) b.trocarCampanha(_g.trocarNpc(c, novo));
    return _ja(novo);
  }

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) {
    b.passo('npcs.atualizar');
    for (final c in b.campanhas) {
      for (final n in c.npcs) {
        if (n.id == id) {
          b.trocarCampanha(
            _g.trocarNpc(c, Npc.fromJson({...n.toJson(), ...campos})),
          );
        }
      }
    }
    return _ja(null);
  }

  @override
  Future<void> apagar(String id) {
    b.passo('npcs.apagar');
    for (final c in b.campanhas) {
      b.trocarCampanha(
        c.copyWith(
          npcs: [
            for (final n in c.npcs)
              if (n.id != id) n,
          ],
        ),
      );
    }
    return _ja(null);
  }
}

// rpcs da mesa com as mesmas regras do banco, usando os gerenciadores
class MesaServiceFalso implements MesaService {
  MesaServiceFalso(this.b);

  final BancoFalso b;

  static const _inventario = GerenciadorInventario();

  Never _erro(TipoErroBanco tipo) => throw BancoErro(tipo);

  Campanha _doMestre(String id) {
    final c = b.campanha(id);
    if (c == null || c.mestreId != b.usuarioId) {
      _erro(TipoErroBanco.semPermissao);
    }
    return c;
  }

  // roda no gerenciador e grava campanha e herois
  void _mesa(Campanha c, void Function(GerenciadorMesa m) acao) {
    final mesa = GerenciadorMesa(campanha: c, herois: b.heroisDe(c.id));
    acao(mesa);
    b.trocarCampanha(mesa.campanha);
    b.trocarHerois(mesa.herois);
  }

  @override
  Future<String> entrarCampanha(String codigo, String personagemId) {
    b.passo('mesa.entrarCampanha');
    final alvo = codigo.trim().toUpperCase();
    final c = b.campanhas.where((c) => c.codigoConvite == alvo).firstOrNull;
    if (c == null) _erro(TipoErroBanco.codigoInvalido);
    final p = b.personagem(personagemId);
    if (p == null || p.donoId != b.usuarioId) _erro(TipoErroBanco.semPermissao);
    if (c.mestreId == b.usuarioId) _erro(TipoErroBanco.mestreNaoJoga);
    if (p.campanhaId == c.id) return _ja(c.id);
    if (p.campanhaId != null) _erro(TipoErroBanco.heroiEmOutraCampanha);
    if (b.heroisDe(c.id).any((h) => h.donoId == b.usuarioId)) {
      _erro(TipoErroBanco.jaTemHeroi);
    }
    b.trocarHerois([p.copyWith(campanhaId: c.id)]);
    return _ja(c.id);
  }

  void _semCampanha(String personagemId) {
    final p = b.personagem(personagemId);
    if (p != null) {
      b.trocarHerois([const GerenciadorPersonagens().semCampanha(p)]);
    }
  }

  @override
  Future<void> sairCampanha(String personagemId) {
    b.passo('mesa.sairCampanha');
    _semCampanha(personagemId);
    return _ja(null);
  }

  @override
  Future<void> removerHeroi(String personagemId) {
    b.passo('mesa.removerHeroi');
    final p = b.personagem(personagemId);
    _doMestre(p?.campanhaId ?? '');
    _semCampanha(personagemId);
    return _ja(null);
  }

  @override
  Future<String> novoCodigo(String campanhaId) {
    b.passo('mesa.novoCodigo');
    final c = _doMestre(campanhaId);
    final codigo =
        '${c.codigoConvite.split('-').first}-${9000 + b.vezes('mesa.novoCodigo')}';
    b.trocarCampanha(c.copyWith(codigoConvite: codigo));
    return _ja(codigo);
  }

  @override
  Future<int> iniciarSessao(String campanhaId) {
    b.passo('mesa.iniciarSessao');
    final c = _doMestre(campanhaId);
    if (c.emSessao) _erro(TipoErroBanco.sessaoAberta);
    var numero = 0;
    _mesa(c, (m) => numero = m.iniciarSessao());
    return _ja(numero);
  }

  @override
  Future<void> encerrarSessao(String campanhaId, String resumo) {
    b.passo('mesa.encerrarSessao');
    final c = _doMestre(campanhaId);
    if (!c.emSessao) _erro(TipoErroBanco.semSessao);
    _mesa(c, (m) => m.encerrarSessao(resumo));
    return _ja(null);
  }

  @override
  Future<void> darXp(String campanhaId, Set<String> personagemIds, int valor) {
    b.passo('mesa.darXp');
    final c = _doMestre(campanhaId);
    if (personagemIds.any((id) => b.personagem(id)?.campanhaId != c.id)) {
      _erro(TipoErroBanco.semPermissao);
    }
    _mesa(c, (m) => m.darXp(valor, personagemIds));
    return _ja(null);
  }

  @override
  Future<void> darItem(
    String campanhaId,
    String personagemId,
    ItemInventario item, {
    required String itemKey,
    required String nome,
  }) {
    b.passo('mesa.darItem');
    final c = _doMestre(campanhaId);
    final p = b.personagem(personagemId);
    if (p == null || p.campanhaId != c.id) _erro(TipoErroBanco.semPermissao);
    b.trocarHerois([_inventario.receber(p, item)]);
    b.trocarCampanha(
      c.copyWith(
        registros: [
          GerenciadorMesa.novoRegistro(
            c.id,
            TipoRegistro.item,
            '$nome para ${p.nome}',
            personagemId: p.id,
            itemKey: itemKey,
          ),
          ...c.registros,
        ],
      ),
    );
    return _ja(null);
  }

  @override
  Future<void> desfazer(String registroId) {
    b.passo('mesa.desfazer');
    final c = b.campanhas
        .where((c) => c.registros.any((r) => r.id == registroId))
        .firstOrNull;
    if (c == null) _erro(TipoErroBanco.semPermissao);
    _doMestre(c.id);
    final r = c.registros.firstWhere((r) => r.id == registroId);
    _mesa(c, (m) => m.desfazer(r));
    return _ja(null);
  }

  @override
  Future<void> concluirMissao(
    String missaoId, {
    required Map<String, String> destinos,
    required Map<String, ItemInventario> itens,
  }) {
    b.passo('mesa.concluirMissao');
    final (c, m) = b.missao(missaoId);
    _doMestre(c.id);
    if (!m.ativa) _erro(TipoErroBanco.missaoFechada);
    final g = GerenciadorMissoes(missao: m, herois: b.heroisDe(c.id))
      ..concluir(destinos);
    _mesa(c, (mesa) => mesa.aplicarMissao(g.retorno));
    return _ja(null);
  }

  @override
  Future<void> falharMissao(String missaoId) {
    b.passo('mesa.falharMissao');
    final (c, m) = b.missao(missaoId);
    _doMestre(c.id);
    if (!m.ativa) _erro(TipoErroBanco.missaoFechada);
    final g = GerenciadorMissoes(missao: m, herois: b.heroisDe(c.id))..falhar();
    _mesa(c, (mesa) => mesa.aplicarMissao(g.retorno));
    return _ja(null);
  }

  @override
  Future<void> apagarMinhaConta() {
    b.passo('mesa.apagarMinhaConta');
    final eu = b.usuarioId;
    final minhas = {
      for (final c in b.campanhas)
        if (c.mestreId == eu) c.id,
    };
    b.campanhas = [
      for (final c in b.campanhas)
        if (!minhas.contains(c.id)) c,
    ];
    b.personagens = [
      for (final p in b.personagens)
        if (p.donoId != eu)
          minhas.contains(p.campanhaId)
              ? const GerenciadorPersonagens().semCampanha(p)
              : p,
    ];
    return _ja(null);
  }
}

// guarda quem esta ouvindo; emitir imita um evento do banco
class RealtimeServiceFalso implements RealtimeService {
  final campanhas = <String, List<void Function()>>{};
  final herois = <String, List<void Function()>>{};

  int get abertas =>
      [...campanhas.values, ...herois.values].fold(0, (s, l) => s + l.length);

  void emitir(String campanhaId) {
    for (final f in [...?campanhas[campanhaId]]) {
      f();
    }
  }

  void emitirHerois(String usuarioId) {
    for (final f in [...?herois[usuarioId]]) {
      f();
    }
  }

  CancelarEscuta _guardar(
    Map<String, List<void Function()>> mapa,
    String id,
    void Function() f,
  ) {
    mapa.putIfAbsent(id, () => []).add(f);
    return () async => mapa[id]?.remove(f);
  }

  @override
  CancelarEscuta ouvirCampanha(String campanhaId, void Function() onMudou) =>
      _guardar(campanhas, campanhaId, onMudou);

  @override
  CancelarEscuta ouvirMeusHerois(String usuarioId, void Function() onMudou) =>
      _guardar(herois, usuarioId, onMudou);
}
