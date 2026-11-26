import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/view/grimoire/bestiario/monstro_detalhe.dart';
import 'package:grimorio/view/grimoire/components/busca_compendio.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/view/grimoire/components/linha_compendio.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/model/grimoire.dart';
import 'package:grimorio/model/grimoire_mock.dart';

// Faixas de ND: rótulo → (mínimo, máximo).
const _faixas = <String, (double, double)?>{
  'Todos': null,
  'ND 0–1': (0, 1),
  'ND 2–4': (2, 4),
  'ND 5–10': (5, 10),
  'ND 11+': (11, 30),
};

const _tipos = ['Humanoide', 'Fera', 'Morto-vivo', 'Gigante', 'Dragão'];

class Bestiario extends StatefulWidget {
  const Bestiario({super.key});

  @override
  State<Bestiario> createState() => _BestiarioState();
}

class _BestiarioState extends State<Bestiario> {
  String _busca = '';
  String _faixa = 'Todos';
  String? _tipo;

  bool _passa(Monstro m) {
    final faixa = _faixas[_faixa];
    return contem(m.nome, _busca) &&
        (faixa == null || (m.ndValor >= faixa.$1 && m.ndValor <= faixa.$2)) &&
        (_tipo == null || m.tipo == _tipo);
  }

  void _abrir(Monstro m) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => MonstroDetalhe(monstro: m)));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filtrados = monstrosMock.where(_passa).toList()
      ..sort((a, b) => a.ndValor.compareTo(b.ndValor));

    return TelaLista(
      titulo: 'Bestiário',
      contagem: monstrosMock.length,
      dicaBusca: 'Buscar criatura',
      onBusca: (v) => setState(() => _busca = v),
      filtros: [
        Filtros(
          itens: [
            for (final f in _faixas.keys)
              Filtro(
                f,
                selecionado: _faixa == f,
                onTap: () => setState(() => _faixa = f),
              ),
          ],
        ),
        Filtros(
          itens: [
            Filtro(
              'Tipo: todos',
              selecionado: _tipo == null,
              onTap: () => setState(() => _tipo = null),
            ),
            for (final t in _tipos)
              Filtro(
                t,
                selecionado: _tipo == t,
                onTap: () => setState(() => _tipo = _tipo == t ? null : t),
              ),
          ],
        ),
      ],
      itens: [
        for (final m in filtrados)
          LinhaCompendio(
            imagem: m.imagem,
            titulo: m.nome,
            subtitulo: '${m.tipo} ${m.tamanho} · ${milhar(m.xp)} XP',
            onTap: () => _abrir(m),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ND ${m.nd}',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.alerta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'CA ${m.ca} · PV ${m.pv}',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
