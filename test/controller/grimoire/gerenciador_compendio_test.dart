import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/grimoire/gerenciador_compendio.dart';
import 'package:grimorio/model/grimoire_mock.dart';

void main() {
  const compendio = GerenciadorCompendio();

  group('busca', () {
    test('ignora acento e maiúscula', () {
      expect(compendio.contem('Poção de Cura', 'POCAO'), isTrue);
    });

    test('busca vazia aceita tudo', () {
      expect(compendio.contem('Goblin', ''), isTrue);
    });
  });

  group('filtrarMagias', () {
    test('truques só tem círculo 0', () {
      final lista = compendio.filtrarMagias(magiasCompendio, circulo: 0);
      expect(lista, isNotEmpty);
      expect(lista.every((m) => m.circulo == 0), isTrue);
    });

    test('círculo 4 pega do 4º para cima', () {
      final lista = compendio.filtrarMagias(magiasCompendio, circulo: 4);
      expect(lista.every((m) => m.circulo >= 4), isTrue);
    });
  });

  group('filtrarItens', () {
    test('armaduras inclui escudo', () {
      final lista = compendio.filtrarItens(
        itensMock,
        tipo: FiltroItem.armaduras,
      );
      expect(
        lista.every(
          (i) => i.categoria == 'Armadura' || i.categoria == 'Escudo',
        ),
        isTrue,
      );
    });

    test('busca sem resultado volta vazio', () {
      expect(compendio.filtrarItens(itensMock, busca: 'zzzz'), isEmpty);
    });
  });

  group('filtrarMonstros', () {
    test('ordena por nd', () {
      final nds = compendio.filtrarMonstros(monstrosMock).map((m) => m.ndValor);
      expect(nds.toList(), [...nds]..sort());
    });

    test('faixa 2 a 4 respeita os limites', () {
      final lista = compendio.filtrarMonstros(monstrosMock, faixa: (2, 4));
      expect(lista.every((m) => m.ndValor >= 2 && m.ndValor <= 4), isTrue);
    });
  });
}
