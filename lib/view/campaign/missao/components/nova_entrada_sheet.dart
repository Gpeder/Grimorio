import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';

Future<EntradaMissao?> pedirEntrada(
  BuildContext context, {
  required int sessao,
}) => showModalBottomSheet<EntradaMissao>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => NovaEntradaSheet(sessao: sessao),
);

class NovaEntradaSheet extends StatefulWidget {
  const NovaEntradaSheet({super.key, required this.sessao});

  final int sessao;

  @override
  State<NovaEntradaSheet> createState() => _NovaEntradaSheetState();
}

class _NovaEntradaSheetState extends State<NovaEntradaSheet> {
  final _texto = TextEditingController();
  bool _objetivo = false;
  bool _revelar = true;
  String? _erro;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _salvar() {
    final texto = _texto.text.trim();
    if (texto.isEmpty) {
      setState(() => _erro = 'Escreva o que aconteceu.');
      return;
    }
    Navigator.pop(
      context,
      EntradaMissao(
        id: novoId('entrada'),
        texto: texto,
        sessao: widget.sessao,
        objetivo: _objetivo,
        revelada: _revelar,
        criadaEm: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium,
          0,
          AppSpacing.medium,
          AppSpacing.medium + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloSecao('Nova entrada · Sessão ${widget.sessao}'),
            TextField(
              key: const ValueKey('entrada-texto'),
              controller: _texto,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'O que aconteceu?',
                errorText: _erro,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('É objetivo?'),
              value: _objetivo,
              onChanged: (v) => setState(() => _objetivo = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Revelar agora?'),
              value: _revelar,
              onChanged: (v) => setState(() => _revelar = v),
            ),
            const SizedBox(height: AppSpacing.small),
            ElevatedButton(
              onPressed: _salvar,
              child: const Text('Adicionar entrada'),
            ),
          ],
        ),
      ),
    );
  }
}
