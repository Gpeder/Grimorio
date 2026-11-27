import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

// so libera depois de digitar APAGAR
Future<bool> confirmarApagarConta(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (_) => const ApagarContaDialog(),
  );
  return ok ?? false;
}

class ApagarContaDialog extends StatefulWidget {
  const ApagarContaDialog({super.key});

  static const palavra = 'APAGAR';

  @override
  State<ApagarContaDialog> createState() => _ApagarContaDialogState();
}

class _ApagarContaDialogState extends State<ApagarContaDialog> {
  final _controle = TextEditingController();

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  bool get _liberado => _controle.text.trim() == ApagarContaDialog.palavra;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apagar conta?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seus heróis, campanhas e o perfil somem para sempre. '
            'Heróis de outros jogadores nas suas campanhas ficam sem campanha.',
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            key: const ValueKey('apagar-conta'),
            controller: _controle,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Digite ${ApagarContaDialog.palavra}',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppSpacing.small),
        TextButton(
          onPressed: _liberado ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            'Apagar',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _liberado
                  ? AppColors.vida
                  : AppColors.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
      ],
    );
  }
}
