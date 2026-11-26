import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/json.dart';
import 'package:grimorio/model/personagem.dart';

void main() {
  group('lerEnum', () {
    test('lê pelo nome', () {
      expect(
        lerEnum(Atributo.values, 'carisma', Atributo.forca),
        Atributo.carisma,
      );
    });

    test('nome inválido volta o padrão', () {
      expect(lerEnum(Atributo.values, 'sorte', Atributo.forca), Atributo.forca);
      expect(lerEnumOuNulo(Atributo.values, 42), isNull);
    });
  });

  group('lerData', () {
    test('lê iso', () {
      expect(lerData('2026-11-20T10:00:00.000'), DateTime(2026, 11, 20, 10));
    });

    test('texto inválido ou null não quebra', () {
      expect(lerDataOuNulo('ontem'), isNull);
      expect(lerDataOuNulo(null), isNull);
      expect(lerData(null), DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
