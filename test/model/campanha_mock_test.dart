import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/model/personagem_mock.dart';

void main() {
  final valfenda = campanhasMock.firstWhere(
    (c) => c.id == 'sombras-de-valfenda',
  );
  final trono = campanhasMock.firstWhere((c) => c.id == 'o-trono-de-cinzas');
  final druida = valfenda.missoes.firstWhere(
    (m) => m.titulo == 'O Druida Desaparecido',
  );

  test('papelDe: u_gustavo é herói em Valfenda e mestre em Trono', () {
    expect(valfenda.papelDe('u_gustavo'), PapelCampanha.heroi);
    expect(trono.papelDe('u_gustavo'), PapelCampanha.mestre);
  });

  test('recompensa do Druida usa uma key real de itensMock', () {
    for (final key in druida.recompensaItens) {
      expect(itensMock.any((i) => i.key == key), isTrue, reason: key);
    }
  });

  test('personagensMock só tem os heróis do usuário', () {
    expect(personagensMock.every((p) => p.donoId == 'u_gustavo'), isTrue);
    expect(todosPersonagensMock, hasLength(4));
  });
}
