import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/personagem_mock.dart';

void main() {
  const campanhas = GerenciadorCampanhas();
  final valfenda = campanhasMock.first;
  final druida = valfenda.missoes.first;

  test('heroisDe só pega os da campanha', () {
    final herois = campanhas.heroisDe(valfenda, todosPersonagensMock);
    expect(herois, isNotEmpty);
    expect(herois.every((h) => h.campanhaId == valfenda.id), isTrue);
  });

  test('semCampanha só pega os livres', () {
    final livre = kaelMock.copyWith(id: 'livre');
    final soltos = campanhas.semCampanha([
      personagemAtivoMock,
      Personagem.fromJson({...livre.toJson(), 'campanha_id': null}),
    ]);
    expect(soltos.map((p) => p.id), ['livre']);
  });

  test('camposMissao manda só o que mudou, sem estado nem entradas', () {
    final depois = druida.copyWith(
      revelada: false,
      recompensaXp: 50,
      estado: EstadoMissao.falhou,
      entradas: const [],
    );
    expect(campanhas.camposMissao(druida, depois), {
      'revelada': false,
      'recompensa_xp': 50,
    });
  });

  test('camposEntrada e camposNpc', () {
    final e = druida.entradas.first;
    expect(campanhas.camposEntrada(e, e.copyWith(revelada: false)), {
      'revelada': false,
    });
    final npc = valfenda.npcs.first;
    expect(campanhas.camposNpc(npc, npc.copyWith(revelado: false)), {
      'revelado': false,
    });
  });

  test('trocar e tirar entrada mexem só na missão certa', () {
    final nova = druida.entradas.first.copyWith(texto: 'mudou');
    final c = campanhas.trocarEntrada(valfenda, druida.id, nova);
    expect(campanhas.missao(c, druida.id)!.entradas.first.texto, 'mudou');

    final sem = campanhas.tirarEntrada(c, druida.id, nova.id);
    expect(
      campanhas.missao(sem, druida.id)!.entradas.length,
      druida.entradas.length - 1,
    );
    expect(sem.missoes.length, valfenda.missoes.length);
  });
}
