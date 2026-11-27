import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/log/erro_amigavel.dart';
import 'package:grimorio/service/api/api_erro.dart';

// loga o erro original e devolve so o texto amigavel
String mensagemDeErro(
  Object erro, {
  StackTrace? stack,
  String tag = TagLog.ui,
  String onde = 'erro',
}) {
  AppLog.erro(tag, onde, erro: erro, stack: stack);
  return erro is ErroAmigavel
      ? erro.mensagem
      : TipoErroApi.desconhecido.mensagem;
}
