import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/json.dart';
import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/banco_rotas.dart';

// campanhas com missoes, npcs e sessoes; os testes usam um falso
abstract class CampanhaService {
  // as que mestro e as que jogo (a rls filtra)
  Future<List<Campanha>> minhas();

  // registros e notas do mestre so vem para o mestre
  Future<Campanha> buscar(String id, {required bool mestre});

  // codigo de convite e mestre nascem no banco
  Future<Campanha> criar({required String nome, required String capitulo});

  // so os campos que mudaram, nunca a linha inteira
  Future<void> atualizar(String id, Map<String, dynamic> campos);
  Future<void> apagar(String id);
  Future<void> editarNotas(String campanhaId, String texto);
}

class SupabaseCampanhaService implements CampanhaService {
  SupabaseCampanhaService(this._banco);

  final Banco _banco;

  // ordem de criacao, o banco nao garante nos aninhados
  static List<Map<String, dynamic>> _porData(
    Object? linhas, [
    String chave = BancoRotas.criadoEm,
  ]) =>
      lerLista(linhas)
        ..sort((a, b) => '${a[chave] ?? ''}'.compareTo('${b[chave] ?? ''}'));

  static Campanha montar(
    Map<String, dynamic> linha, {
    List<Map<String, dynamic>> registros = const [],
    String notasMestre = '',
  }) => Campanha.fromJson({
    ...linha,
    'missoes': [
      for (final m in _porData(linha['missoes']))
        {...m, 'entradas': _porData(m['entradas'])},
    ],
    'npcs': _porData(linha['npcs']),
    'sessoes': _porData(linha['sessoes'], 'numero'),
    'registros': registros,
    'notas_mestre': notasMestre,
  });

  @override
  Future<List<Campanha>> minhas() =>
      _banco.rodar('minhas campanhas', (db) async {
        final linhas = await db
            .from(BancoRotas.campanhas)
            .select(BancoRotas.campanhaInteira)
            .order(BancoRotas.criadoEm);
        return [for (final l in linhas) montar(l)];
      });

  @override
  Future<Campanha> buscar(String id, {required bool mestre}) =>
      _banco.rodar('buscar campanha', (db) async {
        final linha = await db
            .from(BancoRotas.campanhas)
            .select(BancoRotas.campanhaInteira)
            .eq(BancoRotas.id, id)
            .single();
        if (!mestre) return montar(linha);

        final registros = await db
            .from(BancoRotas.registros)
            .select()
            .eq(BancoRotas.campanhaId, id)
            .order(BancoRotas.criadoEm, ascending: false);
        final notas = await db
            .from(BancoRotas.notasMestre)
            .select(BancoRotas.texto)
            .eq(BancoRotas.campanhaId, id)
            .maybeSingle();
        return montar(
          linha,
          registros: registros,
          notasMestre: notas?[BancoRotas.texto] as String? ?? '',
        );
      });

  @override
  Future<Campanha> criar({required String nome, required String capitulo}) =>
      _banco.rodar('criar campanha', (db) async {
        final linha = await db
            .from(BancoRotas.campanhas)
            .insert({'nome': nome, 'capitulo': capitulo})
            .select(BancoRotas.campanhaInteira)
            .single();
        return montar(linha);
      });

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) async {
    if (campos.isEmpty) return;
    await _banco.rodar(
      'atualizar campanha ${campos.keys.join(', ')}',
      (db) =>
          db.from(BancoRotas.campanhas).update(campos).eq(BancoRotas.id, id),
    );
  }

  @override
  Future<void> apagar(String id) => _banco.rodar(
    'apagar campanha',
    (db) => db.from(BancoRotas.campanhas).delete().eq(BancoRotas.id, id),
  );

  @override
  Future<void> editarNotas(String campanhaId, String texto) => _banco.rodar(
    'editar notas do mestre',
    (db) => db
        .from(BancoRotas.notasMestre)
        .update({BancoRotas.texto: texto})
        .eq(BancoRotas.campanhaId, campanhaId),
  );
}
