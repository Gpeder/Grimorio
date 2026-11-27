import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum NivelLog {
  info(800),
  aviso(900),
  erro(1000);

  const NivelLog(this.valor);
  final int valor;
}

// tags fixas, filtraveis no debug console
class TagLog {
  static const api = 'API';
  static const rota = 'ROTA';
  static const provider = 'PROVIDER';
  static const ui = 'UI';
  static const flutter = 'FLUTTER';
  static const app = 'APP';
  static const auth = 'AUTH';
  static const banco = 'BANCO';
}

typedef RelatorioErro = void Function(
  String tag,
  String msg,
  Object? erro,
  StackTrace? stack,
);

class AppLog {
  // ponto para crashlytics ou sentry no futuro
  static RelatorioErro? relatorio;

  // em release so erro sai
  static bool get _ligado => !kReleaseMode;

  static void info(String tag, String msg) {
    if (_ligado) _escrever(NivelLog.info, tag, msg);
  }

  static void aviso(String tag, String msg, {Object? erro}) {
    if (_ligado) _escrever(NivelLog.aviso, tag, msg, erro: erro);
  }

  static void erro(String tag, String msg, {Object? erro, StackTrace? stack}) {
    final pilha = stack ?? StackTrace.current;
    _escrever(NivelLog.erro, tag, msg, erro: erro, stack: pilha);
    relatorio?.call(tag, msg, erro, pilha);
  }

  static void _escrever(
    NivelLog nivel,
    String tag,
    String msg, {
    Object? erro,
    StackTrace? stack,
  }) => developer.log(
    '[$tag] $msg',
    name: tag,
    level: nivel.valor,
    error: erro,
    stackTrace: stack,
  );
}
