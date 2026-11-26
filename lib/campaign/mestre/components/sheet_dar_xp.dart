import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/models/character.dart';

typedef DarXp = ({int valor, Set<String> heroiIds});

Future<DarXp?> pedirXp(
  BuildContext context, {
  required List<Character> herois,
  required Set<String> marcados,
}) => showModalBottomSheet<DarXp>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => SheetDarXp(herois: herois, marcados: marcados),
);

class SheetDarXp extends StatefulWidget {
  const SheetDarXp({super.key, required this.herois, required this.marcados});

  final List<Character> herois;
  final Set<String> marcados;

  @override
  State<SheetDarXp> createState() => _SheetDarXpState();
}

class _SheetDarXpState extends State<SheetDarXp> {
  final _valor = TextEditingController();
  late final Set<String> _ids = {...widget.marcados};

  bool get _todos => _ids.length == widget.herois.length;
  int? get _xp => int.tryParse(_valor.text);
  bool get _pronto => (_xp ?? 0) > 0 && _ids.isNotEmpty;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  void _alternar(String id) => setState(() {
    if (!_ids.remove(id)) _ids.add(id);
  });

  void _alternarTodos() => setState(() {
    if (_todos) {
      _ids.clear();
    } else {
      _ids.addAll(widget.herois.map((h) => h.id));
    }
  });

  void _dar() {
    if (!_pronto) return;
    Navigator.pop(context, (valor: _xp!, heroiIds: {..._ids}));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            const TituloSecao('Dar XP'),
            TextField(
              key: const ValueKey('xp-valor'),
              controller: _valor,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                suffixText: 'XP',
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _dar(),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Para quem?',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Etiqueta('Todos', selecionado: _todos, onTap: _alternarTodos),
                for (final h in widget.herois)
                  Etiqueta(
                    h.nome,
                    selecionado: _ids.contains(h.id),
                    onTap: () => _alternar(h.id),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: _pronto ? _dar : null,
              child: const Text('Dar XP'),
            ),
          ],
        ),
      ),
    );
  }
}
