import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

class AbaDiario extends StatelessWidget {
  const AbaDiario({
    super.key,
    required this.notas,
    required this.onAdicionar,
    required this.onRemover,
  });

  final List<Nota> notas;
  final ValueChanged<Nota> onAdicionar;
  final ValueChanged<String> onRemover;

  static String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  Future<void> _nova(BuildContext context) async {
    final nota = await showDialog<Nota>(
      context: context,
      builder: (_) => const _NovaNota(),
    );
    if (nota != null) onAdicionar(nota);
  }

  void _remover(BuildContext context, Nota nota) {
    onRemover(nota.id);
    mostrarAviso(
      context,
      'Anotação removida',
      acao: 'Desfazer',
      onAcao: () => onAdicionar(nota),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ordenadas = [...notas]..sort((a, b) => b.dataMs.compareTo(a.dataMs));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _nova(context),
          icon: const Icon(Pixel.plus, size: 16),
          label: const Text('Nova anotação'),
        ),
        const SizedBox(height: AppSpacing.medium),
        if (ordenadas.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.large),
            child: Text(
              'Nenhuma anotação ainda',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        for (final n in ordenadas) ...[
          Dismissible(
            key: ValueKey(n.id),
            onDismissed: (_) => _remover(context, n),
            background: const SizedBox.shrink(),
            child: CaixaOpcao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _data(n.data),
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.alerta,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.titulo,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (n.texto.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      n.texto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
        ],
      ],
    );
  }
}

class _NovaNota extends StatefulWidget {
  const _NovaNota();

  @override
  State<_NovaNota> createState() => _NovaNotaState();
}

class _NovaNotaState extends State<_NovaNota> {
  final _titulo = TextEditingController();
  final _texto = TextEditingController();

  @override
  void dispose() {
    _titulo.dispose();
    _texto.dispose();
    super.dispose();
  }

  void _salvar() {
    final agora = DateTime.now();
    Navigator.pop(
      context,
      Nota(
        id: agora.microsecondsSinceEpoch.toString(),
        titulo: _titulo.text.trim(),
        texto: _texto.text.trim(),
        data: agora,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final valido = _titulo.text.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Nova anotação'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titulo,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Título'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.medium - 4),
            TextField(
              controller: _texto,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Texto'),
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
          onPressed: valido ? _salvar : null,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
