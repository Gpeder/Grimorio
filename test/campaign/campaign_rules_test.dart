import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/models/campaign.dart';
import 'package:grimorio/models/campaign_mock.dart';
import 'package:grimorio/models/character_mock.dart';
import 'package:grimorio/models/grimoire_mock.dart';

void main() {
  final valfenda = campanhasMock.firstWhere(
    (c) => c.id == 'sombras-de-valfenda',
  );
  final trono = campanhasMock.firstWhere((c) => c.id == 'o-trono-de-cinzas');
  final druida = valfenda.missoes.firstWhere(
    (m) => m.titulo == 'O Druida Desaparecido',
  );
  const heroi = PapelCampanha.heroi;
  const mestre = PapelCampanha.mestre;

  group('missoesVisiveis', () {
    test('o herói não vê a missão oculta', () {
      final titulos = missoesVisiveis(valfenda, heroi).map((m) => m.titulo);
      expect(titulos, isNot(contains('O Altar Profanado')));
      expect(titulos, hasLength(4));
    });

    test('o mestre vê as 5', () {
      expect(missoesVisiveis(valfenda, mestre), hasLength(5));
    });
  });

  group('entradasVisiveis', () {
    test('herói vê 3, mestre vê 4', () {
      expect(entradasVisiveis(druida, heroi), hasLength(3));
      expect(entradasVisiveis(druida, mestre), hasLength(4));
    });

    test('a mais nova vem primeiro', () {
      final ids = entradasVisiveis(druida, mestre).map((e) => e.id);
      expect(ids, ['dd-4', 'dd-3', 'dd-2', 'dd-1']);
    });
  });

  group('objetivoAtual', () {
    test('para o herói é o último objetivo revelado', () {
      expect(
        objetivoAtual(druida, heroi)?.texto,
        startsWith('Seguir os rastros'),
      );
    });

    test('para o mestre é a entrada oculta', () {
      final atual = objetivoAtual(druida, mestre);
      expect(atual?.revelada, isFalse);
      expect(atual?.texto, startsWith('Descobrir que o culto'));
    });
  });

  group('recompensaVisivel', () {
    test('herói não vê na ativa e vê na concluída', () {
      expect(recompensaVisivel(druida, heroi), isFalse);
      expect(
        recompensaVisivel(
          druida.copyWith(estado: EstadoMissao.concluida),
          heroi,
        ),
        isTrue,
      );
    });

    test('mestre sempre vê', () {
      expect(recompensaVisivel(druida, mestre), isTrue);
    });
  });

  test('papelDe: u_gustavo é herói em Valfenda e mestre em Trono', () {
    expect(valfenda.papelDe('u_gustavo'), PapelCampanha.heroi);
    expect(trono.papelDe('u_gustavo'), PapelCampanha.mestre);
  });

  test('npcsVisiveis esconde a Sacerdotisa Ilsa do herói', () {
    expect(npcsVisiveis(valfenda, heroi).map((n) => n.nome), [
      'Bram',
      'Halvar',
    ]);
    expect(npcsVisiveis(valfenda, mestre), hasLength(3));
  });

  test('podeEditarCampanha só para o mestre', () {
    expect(podeEditarCampanha(mestre), isTrue);
    expect(podeEditarCampanha(heroi), isFalse);
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

  test('gerarCodigoConvite não usa sorteio', () {
    final agora = DateTime.fromMillisecondsSinceEpoch(1234);
    expect(gerarCodigoConvite('Ruínas de Ébano', agora), 'RUNA-34');
    expect(gerarCodigoConvite('Ab', agora), 'ABXX-34');
  });
}
