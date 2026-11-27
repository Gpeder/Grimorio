// regras dos campos de login, devolve a mensagem ou null
abstract final class ValidadorAuth {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _letra = RegExp('[A-Za-z]');
  static final _numero = RegExp(r'\d');
  static final _codigo = RegExp(r'^\d{6}$');

  static String limparNome(String nome) => nome.trim();

  static String limparEmail(String email) => email.trim().toLowerCase();

  static String? nome(String valor) {
    final nome = limparNome(valor);
    if (nome.isEmpty) return 'Digite seu nome.';
    if (nome.length < 2 || nome.length > 40) return 'Nome entre 2 e 40 letras.';
    return null;
  }

  static String? email(String valor) =>
      _email.hasMatch(limparEmail(valor)) ? null : 'E-mail inválido.';

  static String? senha(String valor) {
    final ok =
        valor.length >= 8 && _letra.hasMatch(valor) && _numero.hasMatch(valor);
    return ok ? null : 'Mínimo 8 caracteres, com letra e número.';
  }

  // no login so confere se digitou: conta antiga pode ter regra diferente
  static String? senhaLogin(String valor) =>
      valor.isEmpty ? 'Digite sua senha.' : null;

  static String? confirmar(String senha, String outra) =>
      senha == outra ? null : 'As senhas não batem.';

  static String? codigo(String valor) =>
      _codigo.hasMatch(valor.trim()) ? null : 'Digite os 6 números.';
}
