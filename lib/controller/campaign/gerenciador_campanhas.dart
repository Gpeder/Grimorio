import 'package:grimorio/model/campaign.dart';
import 'package:grimorio/model/character.dart';

class GerenciadorCampanhas {
  const GerenciadorCampanhas();

  List<Character> heroisDe(Campaign c, List<Character> personagens) => [
    for (final p in personagens)
      if (p.campanhaId == c.id) p,
  ];

  Character? heroiDoUsuario(List<Character> herois, String usuarioId) =>
      herois.where((h) => h.donoId == usuarioId).firstOrNull;

  // ignora maiuscula e espaco
  Campaign? buscarPorCodigo(List<Campaign> campanhas, String codigo) {
    final alvo = codigo.trim().toUpperCase();
    return campanhas
        .where((c) => c.codigoConvite.toUpperCase() == alvo)
        .firstOrNull;
  }

  Campaign criar({
    required String nome,
    required String capitulo,
    required String mestreId,
    required DateTime agora,
  }) => Campaign(
    id: 'campanha-${agora.microsecondsSinceEpoch}',
    nome: nome,
    capitulo: capitulo,
    mestreId: mestreId,
    codigoConvite: gerarCodigoConvite(nome, agora),
  );

  // 4 letras do nome + 2 digitos do relogio, ex ABCD-12
  String gerarCodigoConvite(String nome, DateTime agora) {
    final letras = nome
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z]'), '')
        .padRight(4, 'X')
        .substring(0, 4);
    final digitos = (agora.millisecondsSinceEpoch % 100).toString().padLeft(
      2,
      '0',
    );
    return '$letras-$digitos';
  }

  List<Campaign> trocar(List<Campaign> campanhas, Campaign nova) => [
    for (final c in campanhas) c.id == nova.id ? nova : c,
  ];

  List<Character> trocarHerois(
    List<Character> personagens,
    List<Character> alterados,
  ) {
    final porId = {for (final h in alterados) h.id: h};
    return [for (final p in personagens) porId[p.id] ?? p];
  }
}
