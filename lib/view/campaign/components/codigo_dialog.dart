import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

Future<String?> pedirCodigo(BuildContext context) => showDialog<String>(
  context: context,
  useRootNavigator: true,
  builder: (_) => const CodigoDialog(),
);

class CodigoDialog extends StatefulWidget {
  const CodigoDialog({super.key});

  @override
  State<CodigoDialog> createState() => _CodigoDialogState();
}

class _CodigoDialogState extends State<CodigoDialog> {
  final _controle = TextEditingController();

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  void _entrar() {
    final codigo = _controle.text.trim();
    if (codigo.isNotEmpty) Navigator.pop(context, codigo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Código do Mestre'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peça o código ao Mestre da campanha.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _controle,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'ABCD-12'),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _entrar(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppSpacing.small),
        TextButton(
          onPressed: _controle.text.trim().isEmpty ? null : _entrar,
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}
