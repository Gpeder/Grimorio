import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/json.dart';

void main() {
  group('lerEnum', () {
    test('lê pelo nome', () {
      expect(
        lerEnum(Ability.values, 'carisma', Ability.forca),
        Ability.carisma,
      );
    });

    test('nome inválido volta o padrão', () {
      expect(lerEnum(Ability.values, 'sorte', Ability.forca), Ability.forca);
      expect(lerEnumOuNulo(Ability.values, 42), isNull);
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
