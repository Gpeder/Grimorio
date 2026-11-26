import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/condicao_srd.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

class Condicoes extends StatefulWidget {
  const Condicoes({super.key});

  @override
  State<Condicoes> createState() => _CondicoesState();
}

class _CondicoesState extends State<Condicoes> {
  String? _aberta;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _compendio.carregarCondicoes(),
    );
  }

  CompendioProvider get _compendio => context.read<CompendioProvider>();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaLista<CondicaoSrd>(
      titulo: 'Condições',
      estado: c.condicoes,
      onCarregarMais: () => _compendio.carregarMaisCondicoes(),
      onTentarDeNovo: () => _compendio.carregarCondicoes(),
      onAtualizar: () => _compendio.carregarCondicoes(forcar: true),
      vazioTitulo: 'Nenhuma condição encontrada',
      itemBuilder: (_, condicao) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.small),
        child: _CondicaoCard(
          condicao: condicao,
          aberta: _aberta == condicao.key,
          onTap: () => setState(
            () => _aberta = _aberta == condicao.key ? null : condicao.key,
          ),
        ),
      ),
    );
  }
}

class _CondicaoCard extends StatelessWidget {
  const _CondicaoCard({
    required this.condicao,
    required this.aberta,
    required this.onTap,
  });

  final CondicaoSrd condicao;
  final bool aberta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final corpo = textTheme.bodyMedium?.copyWith(
      color: AppColors.onSurface.withValues(alpha: 0.85),
    );

    return CaixaOpcao(
      selecionado: aberta,
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: TraducaoSrd.condicao(condicao.nome),
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '  ${condicao.nome}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  aberta ? Pixel.chevrondown : Pixel.chevronright,
                  size: 16,
                  color: AppColors.alerta,
                ),
              ],
            ),
            if (aberta) ...[
              const SizedBox(height: 6),
              Text(condicao.descricao, style: corpo),
            ],
          ],
        ),
      ),
    );
  }
}
