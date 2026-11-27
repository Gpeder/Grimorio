import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/banco_rotas.dart';

// herois e o diario deles, os testes usam um falso
abstract class PersonagemService {
  // os meus e os das campanhas em que estou (a rls filtra)
  Future<List<Personagem>> visiveis();
  Future<List<Personagem>> meus(String usuarioId);
  Future<List<Personagem>> daCampanha(String campanhaId);

  // nasce sem campanha, de quem esta logado
  Future<Personagem> criar(Personagem p);

  // so os campos que mudaram, nunca a linha inteira
  Future<void> atualizar(String id, Map<String, dynamic> campos);
  Future<void> apagar(String id);

  // troca o heroi ativo do usuario
  Future<void> ativar(String id);

  // diario: notas do usuario agrupadas pelo id do heroi
  Future<Map<String, List<Nota>>> notas();
  Future<Nota> criarNota(String personagemId, Nota nota);
  Future<void> apagarNota(String id);
}

class SupabasePersonagemService implements PersonagemService {
  SupabasePersonagemService(this._banco);

  final Banco _banco;

  // dono, campanha e notas nao vao no insert
  static const _foraDoInsert = {'id', 'dono_id', 'campanha_id', 'notas'};

  static List<Personagem> _lista(List<Map<String, dynamic>> linhas) => [
    for (final l in linhas) Personagem.fromJson(l),
  ];

  @override
  Future<List<Personagem>> visiveis() => _banco.rodar(
    'personagens visiveis',
    (db) async => _lista(
      await db.from(BancoRotas.personagens).select().order(BancoRotas.criadoEm),
    ),
  );

  @override
  Future<List<Personagem>> meus(String usuarioId) => _banco.rodar(
    'meus personagens',
    (db) async => _lista(
      await db
          .from(BancoRotas.personagens)
          .select()
          .eq(BancoRotas.donoId, usuarioId)
          .order(BancoRotas.criadoEm),
    ),
  );

  @override
  Future<List<Personagem>> daCampanha(String campanhaId) => _banco.rodar(
    'personagens da campanha',
    (db) async => _lista(
      await db
          .from(BancoRotas.personagens)
          .select()
          .eq(BancoRotas.campanhaId, campanhaId)
          .order(BancoRotas.criadoEm),
    ),
  );

  @override
  Future<Personagem> criar(Personagem p) =>
      _banco.rodar('criar personagem', (db) async {
        final campos = {
          for (final e in p.toJson().entries)
            if (!_foraDoInsert.contains(e.key)) e.key: e.value,
          'ativo': false,
        };
        final linha = await db
            .from(BancoRotas.personagens)
            .insert(campos)
            .select()
            .single();
        return Personagem.fromJson(linha);
      });

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) async {
    if (campos.isEmpty) return;
    await _banco.rodar(
      'atualizar personagem ${campos.keys.join(', ')}',
      (db) =>
          db.from(BancoRotas.personagens).update(campos).eq(BancoRotas.id, id),
    );
  }

  @override
  Future<void> apagar(String id) => _banco.rodar(
    'apagar personagem',
    (db) => db.from(BancoRotas.personagens).delete().eq(BancoRotas.id, id),
  );

  @override
  Future<void> ativar(String id) => _banco.rodar(
    'ativar personagem',
    (db) => db.rpc<void>(BancoRotas.ativarHeroi, params: {'personagem': id}),
  );

  @override
  Future<Map<String, List<Nota>>> notas() => _banco.rodar('notas', (db) async {
    final linhas = await db
        .from(BancoRotas.notasHeroi)
        .select()
        .order(BancoRotas.criadoEm);
    final porHeroi = <String, List<Nota>>{};
    for (final l in linhas) {
      final id = l[BancoRotas.personagemId] as String? ?? '';
      porHeroi.putIfAbsent(id, () => []).add(Nota.fromJson(l));
    }
    return porHeroi;
  });

  @override
  Future<Nota> criarNota(String personagemId, Nota nota) =>
      _banco.rodar('criar nota', (db) async {
        final linha = await db
            .from(BancoRotas.notasHeroi)
            .insert({
              BancoRotas.personagemId: personagemId,
              'titulo': nota.titulo,
              'texto': nota.texto,
              'data_ms': nota.dataMs,
            })
            .select()
            .single();
        return Nota.fromJson(linha);
      });

  @override
  Future<void> apagarNota(String id) => _banco.rodar(
    'apagar nota',
    (db) => db.from(BancoRotas.notasHeroi).delete().eq(BancoRotas.id, id),
  );
}
