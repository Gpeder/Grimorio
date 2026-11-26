import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/campaign/gerenciador_mesa.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/personagem_mock.dart';

void main() {
  final campanha = campanhasMock.first.copyWith(registros: const []);
  final herois = [
    for (final p in todosPersonagensMock)
      if (p.campanhaId == campanha.id) p,
  ];

  GerenciadorMesa novaMesa() =>
      GerenciadorMesa(campanha: campanha, herois: herois);

  group('sessão', () {
    test('iniciar soma 1 no número e registra', () {
      final mesa = novaMesa();
      final numero = mesa.iniciarSessao();
      expect(numero, campanha.sessaoAtual + 1);
      expect(mesa.campanha.emSessao, isTrue);
      expect(mesa.campanha.registros.first.tipo, TipoRegistro.sessao);
    });

    test('encerrar guarda o xp dado só nesta sessão', () {
      final mesa = novaMesa()..darXp(50, {herois.first.id});
      mesa.iniciarSessao();
      mesa.darXp(100, {herois.first.id});
      mesa.encerrarSessao('Resumo');
      expect(mesa.campanha.emSessao, isFalse);
      expect(mesa.campanha.sessoes.last.xpTotal, 100);
      expect(mesa.campanha.sessoes.last.resumo, 'Resumo');
    });
  });

  group('xp', () {
    test('dar xp soma em cada herói marcado', () {
      final mesa = novaMesa();
      final ids = {for (final h in herois) h.id};
      mesa.darXp(300, ids);
      for (final h in herois) {
        final depois = mesa.herois.firstWhere((x) => x.id == h.id);
        expect(depois.xp, h.xp + 300);
      }
      expect(mesa.campanha.registros, hasLength(herois.length));
    });

    test('desfazer tira o xp e apaga o registro', () {
      final mesa = novaMesa();
      final heroi = herois.first;
      mesa.darXp(300, {heroi.id});
      mesa.desfazer(mesa.campanha.registros.first);
      expect(mesa.herois.first.xp, heroi.xp);
      expect(mesa.campanha.registros, isEmpty);
    });
  });

  test('dar item e desfazer devolve a mochila', () {
    final mesa = novaMesa();
    final heroi = herois.first;
    int unidades(List<Personagem> lista) =>
        lista.first.inventario.fold(0, (s, i) => s + i.quantidade);
    final antes = unidades(mesa.herois);
    mesa.darItem(itensMock.first, heroi.id);
    expect(unidades(mesa.herois), antes + 1);
    mesa.desfazer(mesa.campanha.registros.first);
    expect(unidades(mesa.herois), antes);
  });

  test('registro de sessão não tem desfazer', () {
    final mesa = novaMesa()..iniciarSessao();
    final antes = mesa.campanha.registros.length;
    mesa.desfazer(mesa.campanha.registros.first);
    expect(mesa.campanha.registros, hasLength(antes));
  });

  test('revelarNpc muda só o npc escolhido', () {
    final mesa = novaMesa();
    final npc = campanha.npcs.firstWhere((n) => !n.revelado);
    mesa.revelarNpc(npc, true);
    expect(
      mesa.campanha.npcs.firstWhere((n) => n.id == npc.id).revelado,
      isTrue,
    );
    expect(
      mesa.campanha.npcs.where((n) => n.revelado).length,
      campanha.npcs.where((n) => n.revelado).length + 1,
    );
  });
}
