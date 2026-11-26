import 'package:flutter/foundation.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/controller/characters/gerenciador_personagens.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/personagem_mock.dart';

// todos os herois do app, os do usuario e os das campanhas
class PersonagensProvider extends ChangeNotifier {
  PersonagensProvider({
    List<Personagem> todos = todosPersonagensMock,
    List<Personagem> meus = personagensMock,
  }) : _todos = [...todos],
       _meusIds = {for (final p in meus) p.id};

  List<Personagem> _todos;
  final Set<String> _meusIds;

  static const _personagens = GerenciadorPersonagens();
  static const _campanhas = GerenciadorCampanhas();

  List<Personagem> get todos => List.unmodifiable(_todos);

  // aba herois
  List<Personagem> get meus => [
    for (final p in _todos)
      if (_meusIds.contains(p.id)) p,
  ];

  Personagem? porId(String id) => _todos.where((p) => p.id == id).firstOrNull;

  List<Personagem> daCampanha(Campanha c) => _campanhas.heroisDe(c, _todos);

  // o novo vira o ativo
  void adicionar(Personagem novo) {
    final meus = _personagens.adicionarNovo(this.meus, novo);
    _todos = [..._personagens.trocarTodos(_todos, meus), novo];
    _meusIds.add(novo.id);
    notifyListeners();
  }

  void atualizar(Personagem p) {
    _todos = _personagens.trocar(_todos, p);
    notifyListeners();
  }

  void atualizarVarios(List<Personagem> alterados) {
    _todos = _personagens.trocarTodos(_todos, alterados);
    notifyListeners();
  }
}
