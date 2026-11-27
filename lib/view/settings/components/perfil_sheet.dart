import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/auth/validador_auth.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/widgets/avatar_circle.dart';

Future<Usuario?> mostrarPerfilSheet(BuildContext context, Usuario usuario) {
  return showModalBottomSheet<Usuario>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => PerfilSheet(usuario: usuario),
  );
}

class PerfilSheet extends StatefulWidget {
  const PerfilSheet({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<PerfilSheet> createState() => _PerfilSheetState();
}

class _PerfilSheetState extends State<PerfilSheet> {
  late final _nome = TextEditingController(text: widget.usuario.nome);
  late PapelMesa _papel = widget.usuario.papel;
  late String? _avatar = widget.usuario.avatar;
  String? _erroNome;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = ValidadorAuth.limparNome(_nome.text);
    setState(() => _erroNome = ValidadorAuth.nome(nome));
    if (_erroNome != null) return;

    Navigator.of(
      context,
    ).pop(widget.usuario.copyWith(nome: nome, papel: _papel, avatar: _avatar));
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TituloSecao('Editar perfil'),
              // avatar
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppImages.especies.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.small),
                  itemBuilder: (_, i) {
                    final imagem = AppImages.especies[i];
                    return _OpcaoAvatar(
                      imagem: imagem,
                      selecionado: imagem == _avatar,
                      onTap: () => setState(() => _avatar = imagem),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                key: const ValueKey('perfil-nome'),
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _salvar(),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  errorText: _erroNome,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              // e-mail vem da conta, nao muda aqui
              Text(
                'E-mail',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.usuario.email,
                key: const ValueKey('perfil-email'),
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
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

class _OpcaoAvatar extends StatelessWidget {
  const _OpcaoAvatar({
    required this.imagem,
    required this.selecionado,
    required this.onTap,
  });

  final String imagem;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      label: 'Avatar',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selecionado ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Opacity(
            opacity: selecionado ? 1 : 0.55,
            child: AvatarCircle(imagePath: imagem, radius: 26),
          ),
        ),
      ),
    );
  }
}
