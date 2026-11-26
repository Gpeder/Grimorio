import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/campaign.dart';
import 'package:grimorio/model/campaign_mock.dart';

import 'ida_e_volta.dart';

void main() {
  test('as campanhas do mock voltam iguais', () {
    for (final c in campanhasMock) {
      confereIdaEVolta(c, (x) => x.toJson(), Campaign.fromJson);
    }
  });

  test('missões, entradas, npcs, sessões e registros voltam iguais', () {
    for (final c in campanhasMock) {
      for (final m in c.missoes) {
        confereIdaEVolta(m, (x) => x.toJson(), Missao.fromJson);
        for (final e in m.entradas) {
          confereIdaEVolta(e, (x) => x.toJson(), EntradaMissao.fromJson);
        }
      }
      for (final n in c.npcs) {
        confereIdaEVolta(n, (x) => x.toJson(), Npc.fromJson);
      }
      for (final s in c.sessoes) {
        confereIdaEVolta(s, (x) => x.toJson(), Sessao.fromJson);
      }
      for (final r in c.registros) {
        confereIdaEVolta(r, (x) => x.toJson(), RegistroMesa.fromJson);
      }
    }
  });

  test('datas viram texto iso', () {
    final m = campanhasMock.first.missoes.first;
    expect(m.toJson()['atualizada_em'], m.atualizadaEm.toIso8601String());
  });

  test('opcional null e enum inválido não quebram', () {
    final json = pelaRede(campanhasMock.first.toJson())..['capa'] = null;
    final missao = (json['missoes'] as List).first as Map<String, dynamic>;
    missao['estado'] = 'perdida';
    missao['tipo'] = null;
    final registro = (json['registros'] as List).first as Map<String, dynamic>;
    registro['personagem_id'] = null;
    registro['tipo'] = 'outro';

    final c = Campaign.fromJson(json);
    expect(c.capa, isNull);
    expect(c.missoes.first.estado, EstadoMissao.ativa);
    expect(c.missoes.first.tipo, TipoMissao.secundaria);
    expect(c.registros.first.personagemId, isNull);
    expect(c.registros.first.tipo, TipoRegistro.xp);
  });
}
