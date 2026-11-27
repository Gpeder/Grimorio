import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/settings/components/ajuste_tile.dart';
import 'package:grimorio/view/settings/components/grupo_ajustes.dart';
import 'package:grimorio/view/settings/components/opcoes_sheet.dart';
import 'package:grimorio/view/settings/components/perfil_card.dart';
import 'package:grimorio/view/settings/components/perfil_sheet.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_erro.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Usuario get _u => context.read<UsuarioProvider>().usuario;

  // salva no banco; se falhar o provider volta e o erro aparece
  Future<bool> _salvar(Usuario u) async {
    try {
      await context.read<UsuarioProvider>().atualizar(u);
      return true;
    } catch (e, stack) {
      if (mounted) {
        mostrarErro(
          context,
          e,
          stack: stack,
          onde: 'salvar perfil',
          acimaDaBarra: true,
        );
      }
      return false;
    }
  }

  static const _versao = '0.1.0';

  void _aviso(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo, acimaDaBarra: true);

  void _emBreve() => _aviso('Em breve');

  Future<void> _escolher<T>({
    required String titulo,
    required List<T> opcoes,
    required String Function(T) rotulo,
    required T atual,
    required Usuario Function(T) aplicar,
    String? nota,
  }) async {
    final escolhido = await mostrarOpcoesSheet<T>(
      context,
      titulo: titulo,
      opcoes: opcoes,
      rotulo: rotulo,
      selecionado: atual,
      nota: nota,
    );
    if (escolhido == null || !mounted) return;
    _salvar(aplicar(escolhido));
  }

  Future<void> _editarPerfil() async {
    final novo = await mostrarPerfilSheet(context, _u);
    if (novo == null || !mounted) return;
    if (await _salvar(novo)) {
      _aviso('Perfil atualizado', tipo: Snackbar.sucesso);
    }
  }

  Future<void> _sair() async {
    final confirmou = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: AppSpacing.small),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      // saiu: os providers limpam e o router leva para o login
      await context.read<AuthProvider>().sair();
    } catch (e, stack) {
      if (mounted) {
        mostrarErro(context, e, stack: stack, onde: 'sair', acimaDaBarra: true);
      }
    }
  }

  Future<void> _atualizarCompendio() async {
    await _salvar(_u.copyWith(compendioAtualizadoEm: DateTime.now()));
    if (!mounted) return;
    _aviso('Compêndio atualizado', tipo: Snackbar.sucesso);
  }

  Future<void> _apagarTudo() async {
    final confirmou = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Apagar todos os dados?'),
        content: const Text(
          'Heróis, campanhas e ajustes deste aparelho somem para sempre.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: AppSpacing.small),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Apagar',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.vida),
            ),
          ),
        ],
      ),
    );
    if (confirmou == true && mounted) _emBreve();
  }

  void _creditos() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => const _CreditosSheet(versao: _versao),
    );
  }

  static String _data(DateTime? d) {
    if (d == null) return 'Nunca';
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final usuarios = context.watch<UsuarioProvider>();
    final textTheme = Theme.of(context).textTheme;

    final secoes = <Widget>[
      Text(
        'Ajustes',
        style: textTheme.headlineMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      switch (usuarios.carregamento) {
        Carregamento.carregando => const EstadoCarregando(compacto: true),
        Carregamento.erro => EstadoErro(
          mensagem: usuarios.mensagemErro ?? 'Algo deu errado',
          onTentarDeNovo: usuarios.carregar,
          compacto: true,
        ),
        _ => PerfilCard(
          usuario: _u,
          herois: context.watch<PersonagensProvider>().meus.length,
          campanhas: context.watch<CampanhasProvider>().campanhas.length,
          onEditar: _editarPerfil,
        ),
      },
      GrupoAjustes(
        titulo: 'Regras',
        linhas: [
          AjusteTile(
            icone: Pixel.bookopen,
            titulo: 'Edição das regras',
            valor: _u.edicao.label,
            onTap: () => _escolher(
              titulo: 'Edição das regras',
              opcoes: EdicaoRegras.values,
              rotulo: (e) => e.label,
              atual: _u.edicao,
              aplicar: (e) => _u.copyWith(edicao: e),
            ),
          ),
          AjusteTile(
            icone: Pixel.bookmark,
            titulo: 'Livros adicionais',
            valor: 'Nenhum',
            onTap: _emBreve,
          ),
          AjusteTile(
            icone: Pixel.sparkles,
            titulo: 'Sistema de magia',
            valor: _u.magia.label,
            onTap: () => _escolher(
              titulo: 'Sistema de magia',
              opcoes: SistemaMagia.values,
              rotulo: (m) => m.label,
              atual: _u.magia,
              aplicar: (m) => _u.copyWith(magia: m),
              nota: 'Pontos de magia é uma regra opcional',
            ),
          ),
          AjusteTile(
            icone: Pixel.trendingup,
            titulo: 'Subida de nível',
            valor: _u.subida.label,
            onTap: () => _escolher(
              titulo: 'Subida de nível',
              opcoes: SubidaNivel.values,
              rotulo: (s) => s.label,
              atual: _u.subida,
              aplicar: (s) => _u.copyWith(subida: s),
            ),
          ),
        ],
      ),
      GrupoAjustes(
        titulo: 'Na mesa',
        linhas: [
          AjusteTile.alternar(
            icone: Pixel.infobox,
            titulo: 'Mostrar dicas de bônus',
            subtitulo: '"Ataque +5" ao lado das armas e magias',
            ligado: _u.dicasBonus,
            onChanged: (v) => _salvar(_u.copyWith(dicasBonus: v)),
          ),
          AjusteTile.alternar(
            icone: Pixel.vibrate,
            titulo: 'Vibrar ao tocar',
            ligado: _u.vibrar,
            onChanged: (v) => _salvar(_u.copyWith(vibrar: v)),
          ),
          AjusteTile.alternar(
            icone: Pixel.warningdiamond,
            titulo: 'Confirmar antes de apagar',
            ligado: _u.confirmarApagar,
            onChanged: (v) => _salvar(_u.copyWith(confirmarApagar: v)),
          ),
        ],
      ),
      GrupoAjustes(
        titulo: 'Dados',
        linhas: [
          AjusteTile(
            icone: Pixel.reload,
            titulo: 'Atualizar compêndio',
            valor: _data(_u.compendioAtualizadoEm),
            onTap: _atualizarCompendio,
          ),
          AjusteTile(
            icone: Pixel.download,
            titulo: 'Fazer backup',
            onTap: _emBreve,
          ),
          AjusteTile(
            icone: Pixel.upload,
            titulo: 'Importar backup',
            onTap: _emBreve,
          ),
          AjusteTile(
            icone: Pixel.trash,
            titulo: 'Apagar todos os dados',
            perigoso: true,
            onTap: _apagarTudo,
          ),
        ],
      ),
      GrupoAjustes(
        titulo: 'Conta',
        linhas: [AjusteTile(icone: Pixel.logout, titulo: 'Sair', onTap: _sair)],
      ),
      GrupoAjustes(
        titulo: 'Sobre',
        linhas: [
          const AjusteTile(
            icone: Pixel.infobox,
            titulo: 'Versão',
            valor: _versao,
          ),
          AjusteTile(
            icone: Pixel.script,
            titulo: 'Créditos e licenças',
            onTap: _creditos,
          ),
          AjusteTile(
            icone: Pixel.star,
            titulo: 'Avaliar o app',
            onTap: _emBreve,
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.medium,
            110,
          ),
          itemCount: secoes.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.large),
          itemBuilder: (_, i) => secoes[i],
        ),
      ),
    );
  }
}

class _CreditosSheet extends StatelessWidget {
  const _CreditosSheet({required this.versao});

  final String versao;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: AppColors.onSurface);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          0,
          AppSpacing.medium,
          AppSpacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TituloSecao('Créditos e licenças'),
            Text(
              'Regras: System Reference Document 5.1 (CC BY 4.0), via Open5e',
              style: estilo,
            ),
            const SizedBox(height: AppSpacing.small),
            Text('Ícones: Pixelarticons (MIT)', style: estilo),
            const SizedBox(height: AppSpacing.large),
            TextButton(
              onPressed: () => showLicensePage(
                context: context,
                useRootNavigator: true,
                applicationName: 'Grimório RPG',
                applicationVersion: versao,
              ),
              child: const Text('Licenças do Flutter'),
            ),
          ],
        ),
      ),
    );
  }
}
