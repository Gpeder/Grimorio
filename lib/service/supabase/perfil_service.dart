import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/banco_rotas.dart';

// perfil do usuario na tabela perfis, os testes usam um falso
abstract class PerfilService {
  // sem o e-mail, que vem do auth
  Future<Usuario> buscar(String id);

  // so os campos que mudaram, nunca a linha inteira
  Future<void> atualizar(String id, Map<String, dynamic> campos);

  // nome de quem divide campanha comigo (a rls filtra)
  Future<Map<String, String>> nomes(Iterable<String> ids);
}

class SupabasePerfilService implements PerfilService {
  SupabasePerfilService([Banco? banco]) : _banco = banco ?? Banco();

  final Banco _banco;

  @override
  Future<Usuario> buscar(String id) =>
      _banco.rodar('buscar perfil', (db) async {
        final linha = await db
            .from(BancoRotas.perfis)
            .select()
            .eq(BancoRotas.id, id)
            .single();
        return Usuario.fromJson(linha);
      });

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) async {
    if (campos.isEmpty) return;
    await _banco.rodar(
      'atualizar perfil ${campos.keys.join(', ')}',
      (db) => db.from(BancoRotas.perfis).update(campos).eq(BancoRotas.id, id),
    );
  }

  @override
  Future<Map<String, String>> nomes(Iterable<String> ids) async {
    final lista = ids.toSet().toList();
    if (lista.isEmpty) return {};
    return _banco.rodar('nomes dos perfis', (db) async {
      final linhas = await db
          .from(BancoRotas.perfis)
          .select('${BancoRotas.id}, ${BancoRotas.nome}')
          .inFilter(BancoRotas.id, lista);
      return {
        for (final l in linhas)
          l[BancoRotas.id] as String: l[BancoRotas.nome] as String? ?? '',
      };
    });
  }
}
