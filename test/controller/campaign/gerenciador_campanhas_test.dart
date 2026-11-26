import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/model/campaign_mock.dart';
import 'package:grimorio/model/character_mock.dart';

void main() {
  const campanhas = GerenciadorCampanhas();

  test('gerarCodigoConvite não usa sorteio', () {
    final agora = DateTime.fromMillisecondsSinceEpoch(1234);
    expect(campanhas.gerarCodigoConvite('Ruínas de Ébano', agora), 'RUNA-34');
    expect(campanhas.gerarCodigoConvite('Ab', agora), 'ABXX-34');
  });

  test('criar já vem com código e mestre', () {
    final c = campanhas.criar(
      nome: 'Ruínas de Ébano',
      capitulo: 'Cap. 1',
      mestreId: 'u_x',
      agora: DateTime.fromMillisecondsSinceEpoch(1234),
    );
    expect(c.codigoConvite, 'RUNA-34');
    expect(c.mestreId, 'u_x');
  });

  group('buscarPorCodigo', () {
    test('acha ignorando maiúscula e espaço', () {
      final alvo = campanhasMock.first;
      final achada = campanhas.buscarPorCodigo(
        campanhasMock,
        ' ${alvo.codigoConvite.toLowerCase()} ',
      );
      expect(achada?.id, alvo.id);
    });

    test('código errado volta null', () {
      expect(campanhas.buscarPorCodigo(campanhasMock, 'ZZZZ-00'), isNull);
    });
  });

  test('heroisDe só pega os da campanha', () {
    final c = campanhasMock.first;
    final herois = campanhas.heroisDe(c, todosPersonagensMock);
    expect(herois, isNotEmpty);
    expect(herois.every((h) => h.campanhaId == c.id), isTrue);
  });

  test('trocarHerois mantém quem não mudou', () {
    final kael = todosPersonagensMock.last.copyWith(xp: 1);
    final lista = campanhas.trocarHerois(todosPersonagensMock, [kael]);
    expect(lista, hasLength(todosPersonagensMock.length));
    expect(lista.last.xp, 1);
  });
}
