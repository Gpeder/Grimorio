import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:grimorio/service/supabase/auth_service.dart';

void main() {
  // nos testes nao tem env.json, entao o supabase nao foi iniciado
  test('sem env.json o cadastro avisa que falta configuração', () async {
    final auth = SupabaseAuthService();
    await expectLater(
      auth.cadastrar('Teste', 'teste@exemplo.com', 'Teste1234'),
      throwsA(
        isA<AuthErro>().having(
          (e) => e.tipo,
          'tipo',
          TipoErroAuth.semConfiguracao,
        ),
      ),
    );
    expect(auth.usuarioId, isNull);
  });
}
