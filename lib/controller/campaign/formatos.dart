String _dois(int n) => n.toString().padLeft(2, '0');

// "12/11"
String formatarDia(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}';

// 1200 → "1.200"
String formatarMilhar(int n) {
  final digitos = n.abs().toString();
  final saida = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) saida.write('.');
    saida.write(digitos[i]);
  }
  return saida.toString();
}

// "agora", "há 5 min", "há 2 h", "há 3 dias"
String tempoDesde(DateTime d, {DateTime? agora}) {
  final diff = (agora ?? DateTime.now()).difference(d);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  final dias = diff.inDays;
  return dias == 1 ? 'há 1 dia' : 'há $dias dias';
}

// Ids locais até existir banco. O contador evita repetir dentro do mesmo tique.
var _sequencia = 0;
String novoId(String prefixo) =>
    '$prefixo-${DateTime.now().microsecondsSinceEpoch}-${_sequencia++}';
