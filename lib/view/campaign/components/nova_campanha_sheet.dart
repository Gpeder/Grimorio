import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';

typedef NovaCampanha = ({String nome, String capitulo});

Future<NovaCampanha?> pedirNovaCampanha(BuildContext context) =>
    showModalBottomSheet<NovaCampanha>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const NovaCampanhaSheet(),
    );

class NovaCampanhaSheet extends StatefulWidget {
  const NovaCampanhaSheet({super.key});

  @override
  State<NovaCampanhaSheet> createState() => _NovaCampanhaSheetState();
}

class _NovaCampanhaSheetState extends State<NovaCampanhaSheet> {
  final _nome = TextEditingController();
  final _capitulo = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _capitulo.dispose();
    super.dispose();
  }

  void _criar() {
    final nome = _nome.text.trim();
    if (nome.length < 2) {
      setState(() => _erro = 'Dê um nome à campanha.');
      return;
    }
    Navigator.pop(context, (nome: nome, capitulo: _capitulo.text.trim()));
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
            const TituloSecao('Nova campanha'),
            TextField(
              key: const ValueKey('campanha-nome'),
              controller: _nome,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Nome', errorText: _erro),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: _capitulo,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Capítulo',
                hintText: 'Capítulo 1: O Começo',
              ),
              onSubmitted: (_) => _criar(),
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(onPressed: _criar, child: const Text('Criar')),
          ],
        ),
      ),
    );
  }
}
