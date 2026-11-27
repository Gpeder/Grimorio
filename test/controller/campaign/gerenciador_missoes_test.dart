import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/campaign/gerenciador_missoes.dart';
import 'package:grimorio/model/campanha.dart';

import '../../fixtures/campanha_mock.dart';
import '../../fixtures/personagem_mock.dart';

void main() {
  final campanha = campanhasMock.first;
  final druida = campanha.missoes.firstWhere(
    (m) => m.titulo == 'O Druida Desaparecido',
  );
  final herois = [
    for (final p in todosPersonagensMock)
      if (p.campanhaId == campanha.id) p,
  ];

  GerenciadorMissoes nova() =>
      GerenciadorMissoes(missao: druida, herois: herois);

  group('concluir', () {
    test('dá o xp a todos e o item a quem foi escolhido', () {
      final m = nova();
      final destino = herois.last.id;
      final destinos = {for (final i in m.itensRecompensa) i.key: destino};
      m.concluir(destinos);

      expect(m.missao.estado, EstadoMissao.concluida);
      for (final h in herois) {
        final depois = m.herois.firstWhere((x) => x.id == h.id);
        expect(depois.xp, h.xp + druida.recompensaXp);
      }
      final recebeu = m.herois.firstWhere((h) => h.id == destino);
      expect(
        recebeu.inventario.map((i) => i.id),
        containsAll(druida.recompensaItens),
      );
      expect(m.registros.last.tipo, TipoRegistro.missao);
    });

    test('sem herói o item fica sem dono', () {
      final m = GerenciadorMissoes(missao: druida)..concluir(const {});
      expect(m.herois, isEmpty);
      expect(m.registros.where((r) => r.tipo == TipoRegistro.item), isEmpty);
    });
  });

  test('falhar muda o estado e registra', () {
    final m = nova()..falhar();
    expect(m.missao.estado, EstadoMissao.falhou);
    expect(m.registros.single.texto, contains('falhou'));
  });

  group('recompensa', () {
    test('item repetido não entra duas vezes', () {
      final m = nova();
      final key = druida.recompensaItens.first;
      m.adicionarItem(key);
      expect(m.missao.recompensaItens.where((k) => k == key), hasLength(1));
    });

    test('remover tira o item', () {
      final m = nova()..removerItem(druida.recompensaItens.first);
      expect(
        m.missao.recompensaItens,
        isNot(contains(druida.recompensaItens.first)),
      );
    });
  });

  test('revelar a missão registra só quando fica visível', () {
    final oculta = druida.copyWith(revelada: false);
    final m = GerenciadorMissoes(missao: oculta)..alternarRevelada();
    expect(m.missao.revelada, isTrue);
    expect(m.registros, hasLength(1));
    m.alternarRevelada();
    expect(m.registros, hasLength(1));
  });

  test('apagar entrada tira só ela', () {
    final m = nova();
    final alvo = druida.entradas.first;
    m.apagarEntrada(alvo);
    expect(m.missao.entradas, hasLength(druida.entradas.length - 1));
    expect(m.missao.entradas.any((e) => e.id == alvo.id), isFalse);
  });
}
