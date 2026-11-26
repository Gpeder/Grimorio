import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/grimoire/gerenciador_monstro.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';

import '../../helpers/dio_falso.dart';

void main() {
  const g = GerenciadorMonstro();
  final aboleth = MonstroSrd.fromJson(
    (fixture('monstros.json')['results'] as List).first as Map<String, dynamic>,
  );

  test('atributo mostra valor e modificador', () {
    expect(g.atributo(14), '14 (+2)');
    expect(g.atributo(10), '10 (+0)');
    expect(g.atributo(9), '9 (−1)');
  });

  test('ataque vira bonus em texto, sem rolar', () {
    const mordida = AcaoSrd(
      nome: 'Bite',
      descricao:
          'Melee Weapon Attack: +14 to hit, reach 10 ft., one target. '
          'Hit: 19 (2d10 + 8) piercing damage plus 7 (2d6) fire damage.',
    );
    expect(g.bonus(mordida), ['Ataque +14', '2d10 + 8 perfurante', '2d6 fogo']);
  });

  test('salvaguarda vira CD com a sigla', () {
    const sopro = AcaoSrd(
      nome: 'Fire Breath',
      descricao:
          'Each creature in that area must make a DC 21 Dexterity saving '
          'throw, taking 63 (18d6) fire damage on a failed save.',
      recarga: 5,
    );
    expect(g.bonus(sopro), ['18d6 fogo', 'Salv. DES CD 21']);
    expect(g.nomeAcao(sopro), 'Fire Breath (Recarga 5–6)');
  });

  test('acao sem ataque nao tem bonus', () {
    expect(g.bonus(const AcaoSrd(nome: 'Multiattack')), isEmpty);
  });

  test('linhas do statblock do aboleth', () {
    expect(g.deslocamento(aboleth), '3 m, natação 12 m');
    expect(g.sentidos(aboleth), 'Visão no escuro 36 m, Percepção passiva 20');
    expect(g.salvaguardas(aboleth), 'CON +6, INT +8, SAB +6');
    expect(g.pericias(aboleth), 'História +12, Percepção +10');
    expect(g.linhaTipo(aboleth), startsWith('Aberração Grande'));
  });

  test('lista separa por virgula e ponto e virgula', () {
    expect(
      g.lista(
        'cold; bludgeoning, piercing',
        (v) => v == 'cold' ? 'frio' : '$v!',
      ),
      'frio; bludgeoning!, piercing!',
    );
    expect(g.lista(null, (v) => v ?? ''), '—');
  });
}
