import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/controller/campaign/gerenciador_mesa.dart';
import 'package:grimorio/controller/characters/gerenciador_exp.dart';
import 'package:grimorio/controller/characters/gerenciador_inventario.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/model/personagem.dart';

// estado do diario de uma missao
class GerenciadorMissoes {
  GerenciadorMissoes({required this.missao, List<Personagem> herois = const []})
    : herois = [...herois];

  Missao missao;
  List<Personagem> herois;

  // vai para a mesa quando sai da tela
  final registros = <RegistroMesa>[];

  static const _exp = GerenciadorExp();
  static const _inventario = GerenciadorInventario();

  RetornoMissao get retorno =>
      (missao: missao, herois: herois, registros: registros);

  RegistroMesa _registro(
    TipoRegistro tipo,
    String texto, {
    String? personagemId,
    int? valor,
    String? itemKey,
  }) => GerenciadorMesa.novoRegistro(
    missao.campanhaId,
    tipo,
    texto,
    personagemId: personagemId,
    valor: valor,
    itemKey: itemKey,
  );

  // toda mudanca marca a hora
  void _mudar(Missao Function(Missao m) f) =>
      missao = f(missao).copyWith(atualizadaEm: DateTime.now());

  // entradas

  void trocarEntrada(EntradaMissao nova) => _mudar(
    (m) => m.copyWith(
      entradas: [for (final e in m.entradas) e.id == nova.id ? nova : e],
    ),
  );

  void concluirEntrada(EntradaMissao e) =>
      trocarEntrada(e.copyWith(concluida: true));

  void alternarEntradaRevelada(EntradaMissao e) =>
      trocarEntrada(e.copyWith(revelada: !e.revelada));

  void apagarEntrada(EntradaMissao e) => _mudar(
    (m) => m.copyWith(
      entradas: [
        for (final x in m.entradas)
          if (x.id != e.id) x,
      ],
    ),
  );

  void adicionarEntrada(EntradaMissao e) {
    _mudar((m) => m.copyWith(entradas: [...m.entradas, e]));
    registros.add(
      _registro(TipoRegistro.entrada, 'Nova entrada em ${missao.titulo}'),
    );
  }

  // missao

  void editar(Missao editada) => missao = editada;

  void alternarRevelada() {
    _mudar((m) => m.copyWith(revelada: !m.revelada));
    if (missao.revelada) {
      registros.add(
        _registro(TipoRegistro.missao, 'Missão revelada: ${missao.titulo}'),
      );
    }
  }

  // recompensa

  void definirXp(int xp) => _mudar((m) => m.copyWith(recompensaXp: xp));

  // item repetido nao entra
  void adicionarItem(String key) {
    if (missao.recompensaItens.contains(key)) return;
    _mudar((m) => m.copyWith(recompensaItens: [...m.recompensaItens, key]));
  }

  void removerItem(String key) => _mudar(
    (m) => m.copyWith(
      recompensaItens: [
        for (final k in m.recompensaItens)
          if (k != key) k,
      ],
    ),
  );

  List<ItemCompendio> get itensRecompensa => [
    for (final key in missao.recompensaItens)
      ?itensMock.where((i) => i.key == key).firstOrNull,
  ];

  // fim da missao

  void falhar() {
    _mudar((m) => m.copyWith(estado: EstadoMissao.falhou));
    registros.add(
      _registro(TipoRegistro.missao, 'Missão falhou: ${missao.titulo}'),
    );
  }

  // xp para todos e cada item para o heroi escolhido
  void concluir(Map<String, String> destinos) {
    final xp = missao.recompensaXp;
    final novos = <RegistroMesa>[];
    var lista = [for (final h in herois) xp > 0 ? _exp.adicionar(h, xp) : h];
    if (xp > 0) {
      for (final h in lista) {
        novos.add(
          _registro(
            TipoRegistro.xp,
            '+${formatarMilhar(xp)} XP para ${h.nome}',
            personagemId: h.id,
            valor: xp,
          ),
        );
      }
    }
    for (final item in itensRecompensa) {
      final destino = destinos[item.key];
      final heroi = lista.where((h) => h.id == destino).firstOrNull;
      if (heroi == null) continue;
      lista = [
        for (final h in lista)
          h.id == heroi.id
              ? _inventario.receber(h, _inventario.doCompendio(item))
              : h,
      ];
      novos.add(
        _registro(
          TipoRegistro.item,
          '${item.nome} para ${heroi.nome}',
          personagemId: heroi.id,
          itemKey: item.key,
        ),
      );
    }
    novos.add(
      _registro(TipoRegistro.missao, 'Missão concluída: ${missao.titulo}'),
    );

    herois = lista;
    _mudar((m) => m.copyWith(estado: EstadoMissao.concluida));
    registros.addAll(novos);
  }
}
