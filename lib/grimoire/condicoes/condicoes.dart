import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/grimoire/components/tela_lista.dart';
import 'package:grimorio/models/grimoire.dart';
import 'package:grimorio/models/grimoire_mock.dart';
import 'package:pixelarticons/pixel.dart';

class Condicoes extends StatefulWidget {
  const Condicoes({super.key});

  @override
  State<Condicoes> createState() => _CondicoesState();
}

class _CondicoesState extends State<Condicoes> {
  String? _aberta;

  @override
  Widget build(BuildContext context) {
    return TelaLista(
      titulo: 'Condições',
      contagem: condicoesMock.length,
      itens: [
        for (final c in condicoesMock)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: _CardCondicao(
              condicao: c,
              aberta: _aberta == c.nome,
              onTap: () =>
                  setState(() => _aberta = _aberta == c.nome ? null : c.nome),
            ),
          ),
      ],
    );
  }
}

class _CardCondicao extends StatelessWidget {
  const _CardCondicao({
    required this.condicao,
    required this.aberta,
    required this.onTap,
  });

  final CondicaoInfo condicao;
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
                  child: Text(
                    condicao.nome,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
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
              for (final n in condicao.niveis)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(n, style: corpo),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
