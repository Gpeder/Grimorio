import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/grimoire/texto_limpo.dart';

void main() {
  test('tira negrito, italico e titulo', () {
    expect(
      textoLimpo(
        '## Armor\n**Armor:** None\nA _bag of holding_ and sleight_of_hand',
      ),
      'Armor\nArmor: None\nA bag of holding and sleight_of_hand',
    );
  });

  test('mantem os paragrafos e junta quebras demais', () {
    const texto = 'Primeiro.\r\n\r\nSegundo.\n\n\n\nTerceiro.';
    expect(textoLimpo(texto), 'Primeiro.\n\nSegundo.\n\nTerceiro.');
    expect(paragrafos(texto), ['Primeiro.', 'Segundo.', 'Terceiro.']);
  });

  test('lista vira bolinha e tabela vira linha', () {
    const texto =
        '* A blinded creature cant see.\n'
        '- Attack rolls have advantage.\n'
        '| d4 | Color |\n'
        '|---|---|\n'
        '| 1 | Red |';
    expect(
      textoLimpo(texto),
      '• A blinded creature cant see.\n'
      '• Attack rolls have advantage.\n'
      'd4 · Color\n'
      '1 · Red',
    );
  });

  test('texto vazio nao vira paragrafo', () {
    expect(paragrafos(''), isEmpty);
    expect(paragrafos('  \n\n '), isEmpty);
  });
}
