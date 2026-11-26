import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/log/app_log.dart';

void main() {
  tearDown(() => AppLog.relatorio = null);

  test('erro chega no ponto de extensao com a stack', () {
    String? tag;
    StackTrace? pilha;
    AppLog.relatorio = (t, _, _, s) {
      tag = t;
      pilha = s;
    };
    AppLog.erro(TagLog.api, 'falhou', erro: StateError('x'));
    expect(tag, 'API');
    expect(pilha, isNotNull);
  });

  test('info e aviso nao chamam o relatorio', () {
    var chamou = false;
    AppLog.relatorio = (_, _, _, _) => chamou = true;
    AppLog.info(TagLog.ui, 'ok');
    AppLog.aviso(TagLog.rota, 'cuidado');
    expect(chamou, isFalse);
  });
}
