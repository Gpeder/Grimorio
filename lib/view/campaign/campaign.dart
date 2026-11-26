import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/personagem_mock.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/view/campaign/components/campanha_card.dart';
import 'package:grimorio/view/campaign/components/codigo_dialog.dart';
import 'package:grimorio/view/campaign/components/nova_campanha_sheet.dart';
import 'package:grimorio/view/campaign/heroi/campanha_heroi.dart';
import 'package:grimorio/view/campaign/mestre/campanha_mestre.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<Campaign> createState() => _CampanhaState();
}

class _CampanhaState extends State<Campaign> {
  late List<Campanha> _campanhas = [...campanhasMock];
  late List<Personagem> _personagens = [...todosPersonagensMock];

  static const _acimaDaBarra = 110.0;
  static const _gerenciador = GerenciadorCampanhas();

  void _aviso(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo, acimaDaBarra: true);

  List<Personagem> _heroisDe(Campanha c) =>
      _gerenciador.heroisDe(c, _personagens);

  Future<void> _entrarComCodigo() async {
    final codigo = await pedirCodigo(context);
    if (codigo == null || !mounted) return;
    final campanha = _gerenciador.buscarPorCodigo(_campanhas, codigo);
    if (campanha == null) {
      _aviso('Código não encontrado', tipo: Snackbar.erro);
    } else {
      _aviso('Você entrou em ${campanha.nome}', tipo: Snackbar.sucesso);
    }
  }

  Future<void> _novaCampanha() async {
    final nova = await pedirNovaCampanha(context);
    if (nova == null || !mounted) return;
    final campanha = _gerenciador.criar(
      nome: nova.nome,
      capitulo: nova.capitulo,
      mestreId: usuarioMock.id,
      agora: DateTime.now(),
    );
    setState(() => _campanhas = [..._campanhas, campanha]);
    _aviso('${campanha.nome} criada', tipo: Snackbar.sucesso);
  }

  Future<void> _abrir(Campanha c) async {
    final herois = _heroisDe(c);
    final tela = c.papelDe(usuarioMock.id) == PapelCampanha.mestre
        ? CampanhaMestre(campanha: c, herois: herois)
        : CampanhaHeroi(
            campanha: c,
            heroi: _gerenciador.heroiDoUsuario(herois, usuarioMock.id),
            grupo: herois,
          );

    final r = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<RetornoCampanha>(MaterialPageRoute(builder: (_) => tela));
    if (r == null || !mounted) return;

    setState(() {
      _campanhas = _gerenciador.trocar(_campanhas, r.campanha);
      _personagens = _gerenciador.trocarHerois(_personagens, r.herois);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: _acimaDaBarra),
        child: ElevatedButton.icon(
          onPressed: _novaCampanha,
          icon: const Icon(Pixel.plus),
          label: const Text('Nova campanha'),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.medium,
            _acimaDaBarra,
          ),
          children: [
            Text(
              'Campanhas',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: _entrarComCodigo,
              icon: const Icon(Pixel.users),
              label: const Text('Entrar com código do Mestre'),
            ),
            const SizedBox(height: AppSpacing.large),
            if (_campanhas.isEmpty)
              const _Vazio()
            else
              for (final c in _campanhas) ...[
                CampanhaCard(
                  campanha: c,
                  papel: c.papelDe(usuarioMock.id),
                  herois: _heroisDe(c),
                  onTap: () => _abrir(c),
                ),
                const SizedBox(height: AppSpacing.medium),
              ],
          ],
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
      child: Column(
        children: [
          const ImageFrame(
            imagePath: AppImages.menuMapa,
            width: 96,
            height: 96,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Nenhuma campanha ainda',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
