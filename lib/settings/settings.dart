import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/models/campaign_mock.dart';
import 'package:grimorio/models/character_mock.dart';
import 'package:grimorio/models/usuario.dart';
import 'package:grimorio/models/usuario_mock.dart';
import 'package:grimorio/settings/components/card_perfil.dart';
import 'package:grimorio/settings/components/grupo_ajustes.dart';
import 'package:grimorio/settings/components/linha_ajuste.dart';
import 'package:grimorio/settings/components/sheet_opcoes.dart';
import 'package:grimorio/settings/components/sheet_perfil.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Usuario _u = usuarioMock;

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
    final escolhido = await mostrarSheetOpcoes<T>(
      context,
      titulo: titulo,
      opcoes: opcoes,
      rotulo: rotulo,
      selecionado: atual,
      nota: nota,
    );
    if (escolhido == null || !mounted) return;
    setState(() => _u = aplicar(escolhido));
  }

  Future<void> _editarPerfil() async {
    final novo = await mostrarSheetPerfil(context, _u);
    if (novo == null || !mounted) return;
    setState(() => _u = novo);
    _aviso('Perfil atualizado', tipo: Snackbar.sucesso);
  }

  void _atualizarCompendio() {
    setState(() => _u = _u.copyWith(compendioAtualizadoEm: DateTime.now()));
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
      builder: (context) => const _SheetCreditos(versao: _versao),
    );
  }

  static String _data(DateTime? d) {
    if (d == null) return 'Nunca';
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final secoes = <Widget>[
      Text(
        'Ajustes',
        style: textTheme.headlineMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      CardPerfil(
        usuario: _u,
        herois: personagensMock.length,
        campanhas: campanhasMock.length,
        onEditar: _editarPerfil,
        onEntrar: () => _aviso('Login em breve'),
      ),
      GrupoAjustes(
        titulo: 'Regras',
        linhas: [
          LinhaAjuste(
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
          LinhaAjuste(
            icone: Pixel.bookmark,
            titulo: 'Livros adicionais',
            valor: 'Nenhum',
            onTap: _emBreve,
          ),
          LinhaAjuste(
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
          LinhaAjuste(
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
          LinhaAjuste.alternar(
            icone: Pixel.infobox,
            titulo: 'Mostrar dicas de bônus',
            subtitulo: '"Ataque +5" ao lado das armas e magias',
            ligado: _u.dicasBonus,
            onChanged: (v) => setState(() => _u = _u.copyWith(dicasBonus: v)),
          ),
          LinhaAjuste.alternar(
            icone: Pixel.vibrate,
            titulo: 'Vibrar ao tocar',
            ligado: _u.vibrar,
            onChanged: (v) => setState(() => _u = _u.copyWith(vibrar: v)),
          ),
          LinhaAjuste.alternar(
            icone: Pixel.warningdiamond,
            titulo: 'Confirmar antes de apagar',
            ligado: _u.confirmarApagar,
            onChanged: (v) =>
                setState(() => _u = _u.copyWith(confirmarApagar: v)),
          ),
        ],
      ),
      GrupoAjustes(
        titulo: 'Dados',
        linhas: [
          LinhaAjuste(
            icone: Pixel.reload,
            titulo: 'Atualizar compêndio',
            valor: _data(_u.compendioAtualizadoEm),
            onTap: _atualizarCompendio,
          ),
          LinhaAjuste(
            icone: Pixel.download,
            titulo: 'Fazer backup',
            onTap: _emBreve,
          ),
          LinhaAjuste(
            icone: Pixel.upload,
            titulo: 'Importar backup',
            onTap: _emBreve,
          ),
          LinhaAjuste(
            icone: Pixel.trash,
            titulo: 'Apagar todos os dados',
            perigoso: true,
            onTap: _apagarTudo,
          ),
        ],
      ),
      GrupoAjustes(
        titulo: 'Sobre',
        linhas: [
          const LinhaAjuste(
            icone: Pixel.infobox,
            titulo: 'Versão',
            valor: _versao,
          ),
          LinhaAjuste(
            icone: Pixel.script,
            titulo: 'Créditos e licenças',
            onTap: _creditos,
          ),
          LinhaAjuste(
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

class _SheetCreditos extends StatelessWidget {
  const _SheetCreditos({required this.versao});

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
