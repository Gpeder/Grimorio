import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/campaign/gerenciador_visibilidade.dart';
import 'package:grimorio/model/campaign.dart';
import 'package:grimorio/model/campaign_mock.dart';

void main() {
  final valfenda = campanhasMock.firstWhere(
    (c) => c.id == 'sombras-de-valfenda',
  );
  final druida = valfenda.missoes.firstWhere(
    (m) => m.titulo == 'O Druida Desaparecido',
  );
  const heroi = PapelCampanha.heroi;
  const mestre = PapelCampanha.mestre;
  const vis = GerenciadorVisibilidade();

  group('missoesVisiveis', () {
    test('o herói não vê a missão oculta', () {
      final titulos = vis.missoes(valfenda, heroi).map((m) => m.titulo);
      expect(titulos, isNot(contains('O Altar Profanado')));
      expect(titulos, hasLength(4));
    });

    test('o mestre vê as 5', () {
      expect(vis.missoes(valfenda, mestre), hasLength(5));
    });
  });

  group('entradasVisiveis', () {
    test('herói vê 3, mestre vê 4', () {
      expect(vis.entradas(druida, heroi), hasLength(3));
      expect(vis.entradas(druida, mestre), hasLength(4));
    });

    test('a mais nova vem primeiro', () {
      final ids = vis.entradas(druida, mestre).map((e) => e.id);
      expect(ids, ['dd-4', 'dd-3', 'dd-2', 'dd-1']);
    });
  });

  group('objetivoAtual', () {
    test('para o herói é o último objetivo revelado', () {
      expect(
        vis.objetivoAtual(druida, heroi)?.texto,
        startsWith('Seguir os rastros'),
      );
    });

    test('para o mestre é a entrada oculta', () {
      final atual = vis.objetivoAtual(druida, mestre);
      expect(atual?.revelada, isFalse);
      expect(atual?.texto, startsWith('Descobrir que o culto'));
    });
  });

  group('recompensaVisivel', () {
    test('herói não vê na ativa e vê na concluída', () {
      expect(vis.recompensaVisivel(druida, heroi), isFalse);
      expect(
        vis.recompensaVisivel(
          druida.copyWith(estado: EstadoMissao.concluida),
          heroi,
        ),
        isTrue,
      );
    });

    test('mestre sempre vê', () {
      expect(vis.recompensaVisivel(druida, mestre), isTrue);
    });
  });

  test('npcsVisiveis esconde a Sacerdotisa Ilsa do herói', () {
    expect(vis.npcs(valfenda, heroi).map((n) => n.nome), ['Bram', 'Halvar']);
    expect(vis.npcs(valfenda, mestre), hasLength(3));
  });

  test('podeEditarCampanha só para o mestre', () {
    expect(vis.podeEditarCampanha(mestre), isTrue);
    expect(vis.podeEditarCampanha(heroi), isFalse);
  });
}
