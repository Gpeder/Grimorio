import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

typedef DarItem = ({ItemCompendio item, String? heroiId});

// sem herois so escolhe o item
Future<DarItem?> pedirItem(
  BuildContext context, {
  required List<ItemCompendio> itens,
  List<Personagem> herois = const [],
  String? heroiId,
}) => showModalBottomSheet<DarItem>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => DarItemSheet(itens: itens, herois: herois, heroiId: heroiId),
);

class DarItemSheet extends StatefulWidget {
  const DarItemSheet({
    super.key,
    required this.itens,
    this.herois = const [],
    this.heroiId,
  });

  final List<ItemCompendio> itens;
  final List<Personagem> herois;
  final String? heroiId;

  @override
  State<DarItemSheet> createState() => _DarItemSheetState();
}

class _DarItemSheetState extends State<DarItemSheet> {
  String _busca = '';
  late String? _heroiId = widget.heroiId ?? widget.herois.firstOrNull?.id;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final busca = _busca.trim().toLowerCase();
    final itens = [
      for (final i in widget.itens)
        if (i.nome.toLowerCase().contains(busca)) i,
    ];

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.medium,
            0,
            AppSpacing.medium,
            MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TituloSecao('Dar item'),
              if (widget.herois.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final h in widget.herois)
                      Etiqueta(
                        h.nome,
                        selecionado: h.id == _heroiId,
                        onTap: () => setState(() => _heroiId = h.id),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small + 4),
              ],
              TextField(
                onChanged: (v) => setState(() => _busca = v),
                decoration: const InputDecoration(
                  hintText: 'Buscar item',
                  prefixIcon: Icon(Pixel.search),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Expanded(
                child: ListView.separated(
                  itemCount: itens.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = itens[i];
                    return InkWell(
                      onTap: () => Navigator.pop(context, (
                        item: item,
                        heroiId: _heroiId,
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            ImageFrame(
                              imagePath: item.imagem,
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: AppSpacing.small + 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nome,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    item.categoria,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurface.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
