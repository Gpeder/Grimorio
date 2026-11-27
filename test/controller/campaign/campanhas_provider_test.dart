import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/model/campanha_mock.dart';

void main() {
  test('criar adiciona e notifica', () {
    final c = CampanhasProvider();
    var avisos = 0;
    c.addListener(() => avisos++);

    final nova = c.criar(nome: 'Ruínas', capitulo: 'Cap. 1', mestreId: 'u');
    expect(avisos, 1);
    expect(c.porId(nova.id)?.nome, 'Ruínas');
    expect(c.campanhas, hasLength(campanhasMock.length + 1));
  });

  test('naMesa grava a campanha e os heróis', () {
    final campanhas = CampanhasProvider();
    final personagens = PersonagensProvider();
    final trono = campanhasMock.firstWhere((x) => x.id == 'o-trono-de-cinzas');
    final heroi = personagens.daCampanha(trono).first;

    campanhas.naMesa(trono.id, personagens, (m) => m.darXp(50, {heroi.id}));

    expect(personagens.porId(heroi.id)!.xp, heroi.xp + 50);
    expect(campanhas.porId(trono.id)!.registros.first.valor, 50);
  });

  test('naMesa com id que não existe não muda nada', () {
    final campanhas = CampanhasProvider();
    final personagens = PersonagensProvider();
    var chamou = false;
    campanhas.naMesa('nao-existe', personagens, (_) => chamou = true);
    expect(chamou, isFalse);
  });

  test('adotarMock deixa o usuário logado de mestre da campanha dele', () {
    final c = CampanhasProvider();
    final dele = c.campanhas.where((x) => x.mestreId == usuarioMock.id);
    expect(dele, isNotEmpty);
    final id = dele.first.id;

    c.adotarMock('uuid-real');
    expect(c.porId(id)!.papelDe('uuid-real'), PapelCampanha.mestre);
    expect(c.campanhas.where((x) => x.mestreId == usuarioMock.id), isEmpty);
  });
}
