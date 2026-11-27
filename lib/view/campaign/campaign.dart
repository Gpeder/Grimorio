import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/campaign/components/campanha_card.dart';
import 'package:grimorio/view/campaign/components/codigo_dialog.dart';
import 'package:grimorio/view/campaign/components/nova_campanha_sheet.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_erro.dart';
import 'package:grimorio/widgets/estado_vazio.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<Campaign> createState() => _CampanhaState();
}

class _CampanhaState extends State<Campaign> {
  static const _acimaDaBarra = 110.0;

  void _aviso(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo, acimaDaBarra: true);

  List<Personagem> _heroisDe(Campanha c) =>
      context.read<PersonagensProvider>().daCampanha(c);

  // so herois sem campanha podem entrar
  Future<void> _entrarComCodigo() async {
    final livres = const GerenciadorCampanhas().semCampanha(
      context.read<PersonagensProvider>().meus,
    );
    if (livres.isEmpty) {
      _aviso('Crie um herói sem campanha para entrar.', tipo: Snackbar.erro);
      return;
    }
    final entrada = await pedirCodigo(context, herois: livres);
    if (entrada == null || !mounted) return;
    try {
      final campanha = await context.read<CampanhasProvider>().entrarComCodigo(
        entrada.codigo,
        entrada.personagemId,
      );
      if (mounted) {
        _aviso('Você entrou em ${campanha.nome}', tipo: Snackbar.sucesso);
      }
    } catch (e, stack) {
      if (mounted) {
        mostrarErro(
          context,
          e,
          stack: stack,
          onde: 'entrar com codigo',
          acimaDaBarra: true,
        );
      }
    }
  }

  Future<void> _novaCampanha() async {
    final nova = await pedirNovaCampanha(context);
    if (nova == null || !mounted) return;
    try {
      final campanha = await context.read<CampanhasProvider>().criar(
        nome: nova.nome,
        capitulo: nova.capitulo,
      );
      if (mounted) _aviso('${campanha.nome} criada', tipo: Snackbar.sucesso);
    } catch (e, stack) {
      if (mounted) {
        mostrarErro(
          context,
          e,
          stack: stack,
          onde: 'nova campanha',
          acimaDaBarra: true,
        );
      }
    }
  }

  void _abrir(Campanha c) => context.pushNamed(
    Rotas.nomeCampanha,
    pathParameters: {Rotas.campanhaId: c.id},
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = context.watch<CampanhasProvider>();
    final campanhas = provider.campanhas;
    context.watch<PersonagensProvider>();
    final usuarioId = context.watch<UsuarioProvider>().usuario.id;

    return Scaffold(
      // vazio ja tem o botao no meio da tela
      floatingActionButton:
          provider.carregamento == Carregamento.pronto && campanhas.isEmpty
          ? null
          : Padding(
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
            switch (provider.carregamento) {
              Carregamento.inicial ||
              Carregamento.carregando => const EstadoCarregando(),
              Carregamento.erro => EstadoErro(
                mensagem: provider.mensagemErro ?? 'Algo deu errado',
                onTentarDeNovo: provider.tentarDeNovo,
              ),
              Carregamento.pronto when campanhas.isEmpty => EstadoVazio(
                titulo: 'Nenhuma campanha',
                mensagem: 'Crie a sua ou entre com o código do Mestre.',
                acoes: [
                  ElevatedButton(
                    onPressed: _novaCampanha,
                    child: const Text('Criar campanha'),
                  ),
                  OutlinedButton(
                    onPressed: _entrarComCodigo,
                    child: const Text('Entrar com código'),
                  ),
                ],
              ),
              Carregamento.pronto => Column(
                children: [
                  for (final c in campanhas) ...[
                    CampanhaCard(
                      campanha: c,
                      papel: c.papelDe(usuarioId),
                      herois: _heroisDe(c),
                      onTap: () => _abrir(c),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                  ],
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}
