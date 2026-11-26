import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';

void main() {
  test('valor conhecido traduz, em qualquer caixa ou com hifen', () {
    expect(TraducaoSrd.escola('Evocation'), 'Evocação');
    expect(TraducaoSrd.escola('evocation'), 'Evocação');
    expect(TraducaoSrd.condicao('Blinded'), 'Cego');
    expect(TraducaoSrd.raridade('Very Rare'), 'Muito raro');
    expect(TraducaoSrd.raridade('very-rare'), 'Muito raro');
    expect(TraducaoSrd.tipoMonstro('Dragon'), 'Dragão');
    expect(TraducaoSrd.tamanho('Huge'), 'Enorme');
    expect(TraducaoSrd.tipoDano('Slashing'), 'cortante');
    expect(TraducaoSrd.siglaAtributo('Dexterity'), 'DES');
    expect(TraducaoSrd.pericia('sleight_of_hand'), 'Prestidigitação');
    expect(TraducaoSrd.tempo('bonus-action'), '1 ação bônus');
  });

  test('valor desconhecido volta igual', () {
    expect(TraducaoSrd.escola('Chronurgy'), 'Chronurgy');
    expect(TraducaoSrd.condicao('Dazed'), 'Dazed');
  });

  test('null e vazio viram travessao', () {
    expect(TraducaoSrd.escola(null), '—');
    expect(TraducaoSrd.raridade(''), '—');
    expect(TraducaoSrd.alcance('  '), '—');
  });

  test('quantidade com unidade vira metro, hora, rodada', () {
    expect(TraducaoSrd.alcance('60 feet'), '18 m');
    expect(TraducaoSrd.alcance('5 feet'), '1,5 m');
    expect(TraducaoSrd.alcance('1 mile'), '1,5 km');
    expect(TraducaoSrd.alcance('Self'), 'Pessoal');
    expect(TraducaoSrd.duracao('1 minute'), '1 minuto');
    expect(TraducaoSrd.duracao('8 hours'), '8 horas');
    expect(TraducaoSrd.duracao('1 round'), '1 rodada');
    expect(TraducaoSrd.duracao('instantaneous'), 'Instantânea');
  });

  test('peso, custo e ca de armadura', () {
    expect(TraducaoSrd.quilos(3), '1,5 kg');
    expect(TraducaoSrd.quilos(0), '—');
    expect(TraducaoSrd.custo('15.00'), '15 po');
    expect(TraducaoSrd.custo('0.50'), '5 pp');
    expect(TraducaoSrd.custo('0.01'), '1 pc');
    expect(TraducaoSrd.custo('0.00'), '—');
    expect(
      TraducaoSrd.caArmadura('14 + Dex modifier (max 2)'),
      '14 + mod. Des (máx. 2)',
    );
  });

  test('propriedade com parenteses e defesa com frase', () {
    expect(TraducaoSrd.propriedadeArma('Special (Lance)'), 'Especial (Lance)');
    expect(
      TraducaoSrd.defesa('and slashing from nonmagical attacks'),
      'e cortante de ataques não mágicos',
    );
    expect(TraducaoSrd.defesa('fire'), 'fogo');
    expect(TraducaoSrd.defesa('poisoned'), 'Envenenado');
  });
}
