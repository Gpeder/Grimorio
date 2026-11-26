import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/gerenciador_compendio.dart';
import 'package:grimorio/model/grimoire_mock.dart';
import 'package:grimorio/model/hero_options.dart';
import 'package:grimorio/model/hero_options_mock.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/view/grimoire/components/linha_compendio.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/magias/magia_detalhe.dart';
import 'package:grimorio/widgets/etiqueta.dart';

// Círculo escolhido: null = todas, 4 = "4º+".
const _circulos = <int?, String>{
  null: 'Todas',
  0: 'Truques',
  1: '1º',
  2: '2º',
  3: '3º',
  4: '4º+',
};

class Magias extends StatefulWidget {
  const Magias({super.key});

  @override
  State<Magias> createState() => _MagiasState();
}

class _MagiasState extends State<Magias> {
  String _busca = '';
  int? _circulo;
  String? _classe;
  bool _concentracao = false;
  bool _ritual = false;

  static const _compendio = GerenciadorCompendio();

  Future<void> _escolherClasse() async {
    final escolha = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TituloSecao('Classe'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Etiqueta(
                    'Todas',
                    selecionado: _classe == null,
                    onTap: () => Navigator.pop(sheet, ''),
                  ),
                  for (final c in classesMock)
                    Etiqueta(
                      c.nome,
                      selecionado: _classe == c.nome,
                      onTap: () => Navigator.pop(sheet, c.nome),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (escolha == null) return;
    setState(() => _classe = escolha.isEmpty ? null : escolha);
  }

  void _abrir(SpellOption m) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => MagiaDetalhe(magia: m)));

  @override
  Widget build(BuildContext context) {
    final filtradas = _compendio.filtrarMagias(
      magiasCompendio,
      busca: _busca,
      circulo: _circulo,
      classe: _classe,
      concentracao: _concentracao,
      ritual: _ritual,
    );
    final circulos = {for (final m in filtradas) m.circulo};

    return TelaLista(
      titulo: 'Magias',
      contagem: magiasCompendio.length,
      dicaBusca: 'Buscar magia',
      onBusca: (v) => setState(() => _busca = v),
      filtros: [
        Filtros(
          itens: [
            for (final MapEntry(key: c, value: rotulo) in _circulos.entries)
              Filtro(
                rotulo,
                selecionado: _circulo == c,
                onTap: () => setState(() => _circulo = c),
              ),
          ],
        ),
        Filtros(
          itens: [
            Filtro(
              _classe == null ? 'Classe' : 'Classe: $_classe',
              selecionado: _classe != null,
              onTap: _escolherClasse,
            ),
            Filtro(
              'Concentração',
              selecionado: _concentracao,
              onTap: () => setState(() => _concentracao = !_concentracao),
            ),
            Filtro(
              'Ritual',
              selecionado: _ritual,
              onTap: () => setState(() => _ritual = !_ritual),
            ),
          ],
        ),
      ],
      itens: [
        for (final c in circulos) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.small),
            child: TituloSecao(c == 0 ? 'Truques' : nomeDoCirculo(c)),
          ),
          for (final m in filtradas)
            if (m.circulo == c)
              LinhaCompendio(
                imagem: imagemDaEscola(m.escola),
                titulo: m.nome,
                subtitulo: m.linha,
                tags: TagsMagia(magia: m),
                onTap: () => _abrir(m),
              ),
        ],
      ],
    );
  }
}

class TagsMagia extends StatelessWidget {
  const TagsMagia({super.key, required this.magia});

  final SpellOption magia;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (magia.concentracao)
          const Etiqueta('C', pequena: true, cor: AppColors.mana),
        if (magia.ritual)
          const Etiqueta('R', pequena: true, cor: AppColors.secondary),
      ],
    );
  }
}
