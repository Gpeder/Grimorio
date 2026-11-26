import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/models/usuario.dart';

Future<Usuario?> mostrarSheetPerfil(BuildContext context, Usuario usuario) {
  return showModalBottomSheet<Usuario>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => SheetPerfil(usuario: usuario),
  );
}

class SheetPerfil extends StatefulWidget {
  const SheetPerfil({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<SheetPerfil> createState() => _SheetPerfilState();
}

class _SheetPerfilState extends State<SheetPerfil> {
  late final _nome = TextEditingController(text: widget.usuario.nome);
  late final _email = TextEditingController(text: widget.usuario.email);
  late PapelMesa _papel = widget.usuario.papel;
  String? _erroNome;
  String? _erroEmail;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _nome.text.trim();
    final email = _email.text.trim();
    final letras = nome.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');

    setState(() {
      _erroNome = letras.length < 2 ? 'Use pelo menos 2 letras.' : null;
      _erroEmail = email.contains('@') ? null : 'E-mail inválido.';
    });
    if (_erroNome != null || _erroEmail != null) return;

    Navigator.of(context)
        .pop(widget.usuario.copyWith(nome: nome, email: email, papel: _papel));
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
              const TituloSecao('Editar perfil'),
              TextField(
                key: const ValueKey('perfil-nome'),
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  errorText: _erroNome,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                key: const ValueKey('perfil-email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _salvar(),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  errorText: _erroEmail,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              SegmentedButton<PapelMesa>(
                showSelectedIcon: false,
                segments: [
                  for (final p in PapelMesa.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_papel},
                onSelectionChanged: (s) => setState(() => _papel = s.first),
              ),
              const SizedBox(height: AppSpacing.large),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
