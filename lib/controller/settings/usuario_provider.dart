import 'package:flutter/foundation.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';

// usuario logado e preferencias
class UsuarioProvider extends ChangeNotifier {
  UsuarioProvider({Usuario? usuario}) : _usuario = usuario ?? usuarioMock;

  Usuario _usuario;

  Usuario get usuario => _usuario;

  void atualizar(Usuario novo) {
    _usuario = novo;
    notifyListeners();
  }
}
