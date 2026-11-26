import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/components/dialogo_numero.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/model/character.dart';

const condicoesSrd = [
  'Agarrado',
  'Amedrontado',
  'Atordoado',
  'Caído',
  'Cego',
  'Contido',
  'Enfeitiçado',
  'Envenenado',
  'Exausto',
  'Incapacitado',
  'Inconsciente',
  'Invisível',
  'Paralisado',
  'Petrificado',
  'Surdo',
];

class FichaCondicoes extends StatelessWidget {
  const FichaCondicoes({
    super.key,
    required this.condicoes,
    required this.onAdicionar,
    required this.onRemover,
  });

  final List<Condition> condicoes;
  final ValueChanged<Condition> onAdicionar;
  final ValueChanged<String> onRemover;

  Future<void> _remover(BuildContext context, Condition c) async {
    final ok = await confirmar(
      context,
      titulo: 'Remover ${c.nome}?',
      sim: 'Remover',
    );
    if (ok) onRemover(c.nome);
  }

  Future<void> _adicionar(BuildContext context) async {
    final nova = await showModalBottomSheet<Condition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const _NovaCondicao(),
    );
    if (nova != null) onAdicionar(nova);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final c in condicoes)
          Etiqueta(
            c.rodadas == null ? c.nome : '${c.nome} · ${c.rodadas}',
            cor: AppColors.vida,
            onTap: () => _remover(context, c),
          ),
        Etiqueta('+ Condição', onTap: () => _adicionar(context)),
      ],
    );
  }
}

class _NovaCondicao extends StatefulWidget {
  const _NovaCondicao();

  @override
  State<_NovaCondicao> createState() => _NovaCondicaoState();
}

class _NovaCondicaoState extends State<_NovaCondicao> {
  String? _nome;
  final _rodadas = TextEditingController();

  @override
  void dispose() {
    _rodadas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nome = _nome;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.large,
        AppSpacing.medium,
        AppSpacing.medium + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova condição',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in condicoesSrd)
                  Etiqueta(
                    c,
                    selecionado: c == _nome,
                    onTap: () => setState(() => _nome = c),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: _rodadas,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: const InputDecoration(
                labelText: 'Rodadas (opcional)',
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: nome == null
                    ? null
                    : () => Navigator.pop(
                        context,
                        Condition(
                          nome: nome,
                          rodadas: int.tryParse(_rodadas.text),
                        ),
                      ),
                child: const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
