import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/auth/validador_auth.dart';

void main() {
  group('nome', () {
    test('vazio pede o nome', () {
      expect(ValidadorAuth.nome('   '), 'Digite seu nome.');
    });

    test('fora de 2 a 40 letras', () {
      expect(ValidadorAuth.nome('A'), 'Nome entre 2 e 40 letras.');
      expect(ValidadorAuth.nome('A' * 41), 'Nome entre 2 e 40 letras.');
    });

    test('bom, contando sem os espaços das pontas', () {
      expect(ValidadorAuth.nome('  Gu  '), isNull);
      expect(ValidadorAuth.nome('A' * 40), isNull);
      expect(ValidadorAuth.limparNome('  Gustavo '), 'Gustavo');
    });
  });

  group('email', () {
    test('ruim', () {
      for (final e in [
        '',
        'gustavo',
        'gustavo@',
        'gu@email',
        'g u@email.com',
      ]) {
        expect(ValidadorAuth.email(e), 'E-mail inválido.', reason: e);
      }
    });

    test('com espaço e maiúscula passa limpo', () {
      expect(ValidadorAuth.email('  Gustavo@Email.COM '), isNull);
      expect(
        ValidadorAuth.limparEmail('  Gustavo@Email.COM '),
        'gustavo@email.com',
      );
    });
  });

  group('senha', () {
    const regra = 'Mínimo 8 caracteres, com letra e número.';

    test('curta, sem letra ou sem número', () {
      expect(ValidadorAuth.senha('abc123'), regra);
      expect(ValidadorAuth.senha('12345678'), regra);
      expect(ValidadorAuth.senha('abcdefgh'), regra);
    });

    test('boa', () {
      expect(ValidadorAuth.senha('abcd1234'), isNull);
    });

    test('no login só confere se digitou', () {
      expect(ValidadorAuth.senhaLogin(''), 'Digite sua senha.');
      expect(ValidadorAuth.senhaLogin('x'), isNull);
    });
  });

  test('confirmar senha', () {
    expect(
      ValidadorAuth.confirmar('abcd1234', 'abcd1235'),
      'As senhas não batem.',
    );
    expect(ValidadorAuth.confirmar('abcd1234', 'abcd1234'), isNull);
  });

  test('código de 6 números', () {
    for (final c in ['', '12345', '1234567', '12a456']) {
      expect(ValidadorAuth.codigo(c), 'Digite os 6 números.', reason: c);
    }
    expect(ValidadorAuth.codigo('123456'), isNull);
  });
}
