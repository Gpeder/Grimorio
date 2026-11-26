import 'package:flutter/material.dart';

class NotasTab extends StatefulWidget {
  const NotasTab({super.key, required this.texto, required this.onChanged});

  final String texto;
  final ValueChanged<String> onChanged;

  @override
  State<NotasTab> createState() => _NotasTabState();
}

class _NotasTabState extends State<NotasTab> {
  late final _controle = TextEditingController(text: widget.texto);

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controle,
      onChanged: widget.onChanged,
      minLines: 10,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Só você vê isto',
        hintText: 'Segredos, ganchos, nomes de NPCs…',
        alignLabelWithHint: true,
      ),
    );
  }
}
