import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';

class GerenciadorCampanhas {
  const GerenciadorCampanhas();

  List<Personagem> heroisDe(Campanha c, List<Personagem> personagens) => [
    for (final p in personagens)
      if (p.campanhaId == c.id) p,
  ];

  Personagem? heroiDoUsuario(List<Personagem> herois, String usuarioId) =>
      herois.where((h) => h.donoId == usuarioId).firstOrNull;

  // ignora maiuscula e espaco
  Campanha? buscarPorCodigo(List<Campanha> campanhas, String codigo) {
    final alvo = codigo.trim().toUpperCase();
    return campanhas
        .where((c) => c.codigoConvite.toUpperCase() == alvo)
        .firstOrNull;
  }

  Campanha criar({
    required String nome,
    required String capitulo,
    required String mestreId,
    required DateTime agora,
  }) => Campanha(
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

  List<Campanha> trocar(List<Campanha> campanhas, Campanha nova) => [
    for (final c in campanhas) c.id == nova.id ? nova : c,
  ];

  List<Personagem> trocarHerois(
    List<Personagem> personagens,
    List<Personagem> alterados,
  ) {
    final porId = {for (final h in alterados) h.id: h};
    return [for (final p in personagens) porId[p.id] ?? p];
  }
}
