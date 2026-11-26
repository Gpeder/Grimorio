import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_criacao.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/hero_options.dart';
import 'package:grimorio/model/hero_options_mock.dart';

SpeciesOption _especie(String key) =>
    especiesMock.firstWhere((e) => e.key == key);

void main() {
  group('bônus de espécie', () {
    test('Elfo + Alto Elfo dá DES +2 e INT +1', () {
      final elfo = _especie('srd_elf');
      final alto = elfo.subespecies.single;

      int bonus(Ability a) =>
          GerenciadorCriacao.bonusDeEspecie(a, especie: elfo, subespecie: alto);

      expect(bonus(Ability.destreza), 2);
      expect(bonus(Ability.inteligencia), 1);
      expect(bonus(Ability.forca), 0);
    });

    test('Meio-Elfo dá CAR +2 e +1 nos 2 atributos escolhidos', () {
      final meioElfo = _especie('srd_half-elf');
      const livres = {Ability.destreza, Ability.sabedoria};

      int bonus(Ability a) => GerenciadorCriacao.bonusDeEspecie(
        a,
        especie: meioElfo,
        livres: livres,
      );

      expect(bonus(Ability.carisma), 2);
      expect(bonus(Ability.destreza), 1);
      expect(bonus(Ability.sabedoria), 1);
      expect(bonus(Ability.forca), 0);
    });
  });

  group('compra de pontos', () {
    test('27 pontos é válido', () {
      const valores = [15, 15, 15, 8, 8, 8];
      expect(GerenciadorCriacao.pontosGastos(valores), 27);
      expect(GerenciadorCriacao.compraValida(valores), isTrue);
    });

    test('28 pontos não é válido', () {
      const valores = [15, 15, 15, 9, 8, 8];
      expect(GerenciadorCriacao.pontosGastos(valores), 28);
      expect(GerenciadorCriacao.compraValida(valores), isFalse);
    });

    test('valor fora de 8–15 não é válido', () {
      expect(
        GerenciadorCriacao.compraValida(const [16, 8, 8, 8, 8, 8]),
        isFalse,
      );
    });
  });

  group('HP do nível 1', () {
    test('Clérigo com CON 14 tem 10', () {
      expect(GerenciadorCriacao.hpNivel1(dadoDeVida: 8, constituicao: 14), 10);
    });

    test('Anão da Colina com CON 16 tem 12', () {
      expect(
        GerenciadorCriacao.hpNivel1(
          dadoDeVida: 8,
          constituicao: 16,
          extraPorNivel: 1,
        ),
        12,
      );
    });

    test('Bárbaro com CON 14 tem 14', () {
      expect(GerenciadorCriacao.hpNivel1(dadoDeVida: 12, constituicao: 14), 14);
    });
  });

  group('CA', () {
    test('cota de escamas + DES 14 + escudo = 18', () {
      final ca = GerenciadorCriacao.calcularCA(
        destreza: 14,
        constituicao: 10,
        sabedoria: 10,
        armadura: TipoArmadura.escamas,
        escudo: true,
      );
      expect(ca, 18);
    });

    test('Monge com DES 16 e SAB 14 = 15', () {
      final ca = GerenciadorCriacao.calcularCA(
        destreza: 16,
        constituicao: 10,
        sabedoria: 14,
        classeKey: 'srd_monk',
      );
      expect(ca, 15);
    });
  });

  test('limiteDeMagias usa o atributo de preparo, com mínimo 1', () {
    final clerigo = classesMock.firstWhere((c) => c.key == 'srd_cleric');
    expect(GerenciadorCriacao.limiteDeMagias(clerigo, valorAtributo: 16), 4);
    expect(GerenciadorCriacao.limiteDeMagias(clerigo, valorAtributo: 6), 1);
  });

  group('rascunho', () {
    test('passo 1 pede espécie e libera ao escolher', () {
      final c = GerenciadorCriacao();
      expect(c.pendencia, isNotNull);
      c.escolherEspecie(_especie('srd_elf'));
      expect(c.pendencia, isNull);
    });

    test('classe sem magia pula o passo 7', () {
      final c = GerenciadorCriacao()
        ..classe = classesMock.firstWhere((x) => !x.temMagia)
        ..passo = 6;
      c.avancar();
      expect(c.passo, 8);
      c.recuar();
      expect(c.passo, 6);
    });

    test('compra acima de 27 pontos é recusada', () {
      final c = GerenciadorCriacao()..mudarModo(ModoAtributos.compra);
      expect(c.mudarValor(Ability.forca, 15), isTrue);
      expect(c.mudarValor(Ability.destreza, 15), isTrue);
      expect(c.mudarValor(Ability.constituicao, 15), isTrue);
      expect(c.mudarValor(Ability.inteligencia, 9), isFalse);
      expect(c.base[Ability.inteligencia], 8);
    });
  });
}
