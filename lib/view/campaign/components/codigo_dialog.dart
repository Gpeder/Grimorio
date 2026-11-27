import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/widgets/etiqueta.dart';

// codigo digitado e o heroi que entra
typedef EntradaCampanha = ({String codigo, String personagemId});

// herois: so os do usuario sem campanha
Future<EntradaCampanha?> pedirCodigo(
  BuildContext context, {
  required List<Personagem> herois,
}) => showDialog<EntradaCampanha>(
  context: context,
  useRootNavigator: true,
  builder: (_) => CodigoDialog(herois: herois),
);

class CodigoDialog extends StatefulWidget {
  const CodigoDialog({super.key, required this.herois});

  final List<Personagem> herois;

  // ABCD-1234, sem diferenciar maiuscula
  static final formato = RegExp(r'^[A-Z]{4}-\d{4}$');

  static String limpar(String codigo) => codigo.trim().toUpperCase();

  @override
  State<CodigoDialog> createState() => _CodigoDialogState();
}

class _CodigoDialogState extends State<CodigoDialog> {
  final _controle = TextEditingController();
  late String? _heroi = widget.herois.firstOrNull?.id;

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  String get _codigo => CodigoDialog.limpar(_controle.text);

  bool get _pronto => CodigoDialog.formato.hasMatch(_codigo) && _heroi != null;

  void _entrar() {
    final heroi = _heroi;
    if (!_pronto || heroi == null) return;
    Navigator.pop(context, (codigo: _codigo, personagemId: heroi));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final apagado = textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface.withValues(alpha: 0.7),
    );
    final digitou = _controle.text.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Código do Mestre'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peça o código ao Mestre da campanha.', style: apagado),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: _controle,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ABCD-1234',
                errorText: digitou && !CodigoDialog.formato.hasMatch(_codigo)
                    ? 'Formato ABCD-1234'
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _entrar(),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text('Quem entra', style: apagado),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final h in widget.herois)
                  Etiqueta(
                    h.nome,
                    selecionado: h.id == _heroi,
                    onTap: () => setState(() => _heroi = h.id),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppSpacing.small),
        TextButton(
          onPressed: _pronto ? _entrar : null,
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}
