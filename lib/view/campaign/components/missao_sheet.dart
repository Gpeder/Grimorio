import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';

// Sem `missao`, cria uma nova. Com `missao`, edita título, tipo, região e descrição.
Future<Missao?> pedirMissao(
  BuildContext context, {
  required String campanhaId,
  Missao? missao,
}) => showModalBottomSheet<Missao>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => MissaoSheet(campanhaId: campanhaId, missao: missao),
);

class MissaoSheet extends StatefulWidget {
  const MissaoSheet({super.key, required this.campanhaId, this.missao});

  final String campanhaId;
  final Missao? missao;

  @override
  State<MissaoSheet> createState() => _MissaoSheetState();
}

class _MissaoSheetState extends State<MissaoSheet> {
  late final _titulo = TextEditingController(text: widget.missao?.titulo);
  late final _regiao = TextEditingController(text: widget.missao?.regiao);
  late final _descricao = TextEditingController(text: widget.missao?.descricao);
  late TipoMissao _tipo = widget.missao?.tipo ?? TipoMissao.secundaria;
  late bool _revelar = widget.missao?.revelada ?? false;
  String? _erro;

  bool get _editando => widget.missao != null;

  @override
  void dispose() {
    _titulo.dispose();
    _regiao.dispose();
    _descricao.dispose();
    super.dispose();
  }

  void _salvar() {
    final titulo = _titulo.text.trim();
    if (titulo.length < 2) {
      setState(() => _erro = 'Dê um título à missão.');
      return;
    }
    final agora = DateTime.now();
    final base =
        widget.missao ??
        Missao(
          id: novoId('missao'),
          campanhaId: widget.campanhaId,
          titulo: titulo,
          atualizadaEm: agora,
        );
    Navigator.pop(
      context,
      base.copyWith(
        titulo: titulo,
        tipo: _tipo,
        regiao: _regiao.text.trim(),
        descricao: _descricao.text.trim(),
        revelada: _revelar,
        atualizadaEm: agora,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TituloSecao(_editando ? 'Editar missão' : 'Nova missão'),
              TextField(
                key: const ValueKey('missao-titulo'),
                controller: _titulo,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Título',
                  errorText: _erro,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              SegmentedButton<TipoMissao>(
                showSelectedIcon: false,
                segments: [
                  for (final t in TipoMissao.values)
                    ButtonSegment(value: t, label: Text(t.label)),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _regiao,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Região'),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _descricao,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _editando ? 'Revelada aos heróis' : 'Revelar agora?',
                ),
                value: _revelar,
                onChanged: (v) => setState(() => _revelar = v),
              ),
              const SizedBox(height: AppSpacing.small),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(_editando ? 'Salvar' : 'Criar missão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
