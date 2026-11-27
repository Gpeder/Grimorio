import 'dart:async';

import 'package:flutter/material.dart';

// reenviar so depois de 60 s; o codigo acabou de sair quando a tela abre
class ReenviarButton extends StatefulWidget {
  const ReenviarButton({super.key, required this.onReenviar});

  // devolve true se mandou, ai a contagem recomeca
  final Future<bool> Function() onReenviar;

  static const espera = 60;

  @override
  State<ReenviarButton> createState() => _ReenviarButtonState();
}

class _ReenviarButtonState extends State<ReenviarButton> {
  Timer? _timer;
  int _faltam = ReenviarButton.espera;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _contar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _contar() {
    _timer?.cancel();
    _faltam = ReenviarButton.espera;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _faltam--);
      if (_faltam <= 0) t.cancel();
    });
  }

  Future<void> _reenviar() async {
    setState(() => _enviando = true);
    final mandou = await widget.onReenviar();
    if (!mounted) return;
    setState(() {
      _enviando = false;
      if (mandou) _contar();
    });
  }

  static String _tempo(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final liberado = _faltam <= 0 && !_enviando;

    return Center(
      child: TextButton(
        onPressed: liberado ? _reenviar : null,
        child: Text(
          _faltam > 0 ? 'Reenviar em ${_tempo(_faltam)}' : 'Reenviar código',
        ),
      ),
    );
  }
}
