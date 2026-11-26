import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/ficha/components/numero_dialog.dart';
import 'package:grimorio/view/characters/ficha/components/slot_equipamento_tile.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/progress_bar.dart';
import 'package:grimorio/widgets/snack_bar.dart';

String _kg(double v) => v == v.roundToDouble()
    ? '${v.round()}'
    : v.toStringAsFixed(1).replaceAll('.', ',');

class InventarioTab extends StatelessWidget {
  const InventarioTab({
    super.key,
    required this.personagem,
    required this.onEquipar,
    required this.onDesequipar,
    required this.onUsar,
    required this.onRemover,
    required this.onMoedas,
  });

  final Personagem personagem;
  final ValueChanged<String> onEquipar;
  final ValueChanged<String> onDesequipar;
  final ValueChanged<String> onUsar;
  final ValueChanged<String> onRemover;
  final ValueChanged<Moedas> onMoedas;

  static const _colunas = 4;

  void _abrirItem(BuildContext context, ItemInventario item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheet) => _DetalhesItem(
        item: item,
        onEquipar: () {
          Navigator.pop(sheet);
          item.equipado ? onDesequipar(item.id) : onEquipar(item.id);
        },
        onUsar: () {
          Navigator.pop(sheet);
          onUsar(item.id);
        },
        onRemover: () async {
          final ok = await confirmar(
            sheet,
            titulo: 'Remover ${item.nome}?',
            texto: 'O item sai do inventário.',
            sim: 'Remover',
          );
          if (!ok || !sheet.mounted) return;
          Navigator.pop(sheet);
          onRemover(item.id);
        },
      ),
    );
  }

  Future<void> _editarMoeda(
    BuildContext context,
    String titulo,
    int atual,
    Moedas Function(int) nova,
  ) async {
    final valor = await pedirNumero(context, titulo: titulo, inicial: atual);
    if (valor != null) onMoedas(nova(valor));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = personagem;
    final m = p.moedas;
    final mochila = [
      for (final i in p.inventario)
        if (!i.equipado) i,
    ];
    final vazios = mochila.isEmpty
        ? _colunas
        : (_colunas - mochila.length % _colunas) % _colunas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TituloSecao('Equipado'),
              _Boneco(
                personagem: p,
                onTap: (item) => _abrirItem(context, item),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Row(
          children: [
            const Expanded(child: RotuloFicha('Carga')),
            Text(
              '${_kg(p.cargaKg)} / ${_kg(p.cargaMaxKg)} kg',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(
          value: p.cargaKg,
          max: p.cargaMaxKg,
          color: p.cargaKg > p.cargaMaxKg
              ? AppColors.vida
              : AppColors.secondary,
          height: 8,
          showText: false,
        ),
        const SizedBox(height: AppSpacing.medium),
        Row(
          spacing: AppSpacing.small,
          children: [
            Expanded(
              child: _Moeda(
                valor: m.ouro,
                sigla: 'PO',
                onTap: () => _editarMoeda(
                  context,
                  'Peças de ouro',
                  m.ouro,
                  (v) => Moedas(ouro: v, prata: m.prata, cobre: m.cobre),
                ),
              ),
            ),
            Expanded(
              child: _Moeda(
                valor: m.prata,
                sigla: 'PP',
                onTap: () => _editarMoeda(
                  context,
                  'Peças de prata',
                  m.prata,
                  (v) => Moedas(ouro: m.ouro, prata: v, cobre: m.cobre),
                ),
              ),
            ),
            Expanded(
              child: _Moeda(
                valor: m.cobre,
                sigla: 'PC',
                onTap: () => _editarMoeda(
                  context,
                  'Peças de cobre',
                  m.cobre,
                  (v) => Moedas(ouro: m.ouro, prata: m.prata, cobre: v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        TituloSecao(
          'Mochila',
          trailing: TextButton(
            onPressed: () => mostrarAviso(context, 'Em breve'),
            child: const Text('+ Adicionar item'),
          ),
        ),
        GridView.count(
          crossAxisCount: _colunas,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: AppSpacing.small,
          crossAxisSpacing: AppSpacing.small,
          children: [
            for (final item in mochila)
              _ItemMochila(item: item, onTap: () => _abrirItem(context, item)),
            for (var i = 0; i < vazios; i++) const SlotVazioTile(),
          ],
        ),
      ],
    );
  }
}

class _Boneco extends StatelessWidget {
  const _Boneco({required this.personagem, required this.onTap});

  final Personagem personagem;
  final ValueChanged<ItemInventario> onTap;

  @override
  Widget build(BuildContext context) {
    final p = personagem;
    final aneis = p.itensEm(SlotEquipamento.anel);

    Widget slot(SlotEquipamento s, String rotulo, {int indice = 0}) {
      final itens = p.itensEm(s);
      return SlotEquipamentoTile(
        item: indice < itens.length ? itens[indice] : null,
        rotulo: rotulo,
        onTap: onTap,
      );
    }

    const vao = SizedBox(height: AppSpacing.small);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                slot(SlotEquipamento.elmo, 'Elmo'),
                vao,
                slot(SlotEquipamento.colar, 'Colar'),
                vao,
                slot(SlotEquipamento.capa, 'Capa'),
                vao,
                SlotEquipamentoTile(
                  item: aneis.isNotEmpty ? aneis[0] : null,
                  rotulo: 'Anel',
                  onTap: onTap,
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 240, child: SlotVazioTile()),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      'CA ${p.ca}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.alerta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                slot(SlotEquipamento.armadura, 'Armadura'),
                vao,
                slot(SlotEquipamento.luvas, 'Luvas'),
                vao,
                slot(SlotEquipamento.botas, 'Botas'),
                vao,
                SlotEquipamentoTile(
                  item: aneis.length > 1 ? aneis[1] : null,
                  rotulo: 'Anel',
                  onTap: onTap,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpacing.large,
          children: [
            slot(SlotEquipamento.maoPrincipal, 'Mão principal'),
            slot(SlotEquipamento.maoSecundaria, 'Mão secundária'),
          ],
        ),
      ],
    );
  }
}

class _Moeda extends StatelessWidget {
  const _Moeda({required this.valor, required this.sigla, required this.onTap});

  final int valor;
  final String sigla;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CaixaOpcao(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small + 2,
        vertical: AppSpacing.small,
      ),
      child: Row(
        children: [
          Image.asset(
            AppImages.moeda,
            width: 22,
            height: 22,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$valor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sigla,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.alerta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemMochila extends StatelessWidget {
  const _ItemMochila({required this.item, required this.onTap});

  final ItemInventario item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFrame(imagePath: item.imagem, onTap: onTap),
        ),
        if (item.quantidade > 1)
          Positioned(
            top: 4,
            right: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(color: AppColors.alerta),
                ),
                child: Text(
                  '×${item.quantidade}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DetalhesItem extends StatelessWidget {
  const _DetalhesItem({
    required this.item,
    required this.onEquipar,
    required this.onUsar,
    required this.onRemover,
  });

  final ItemInventario item;
  final VoidCallback onEquipar;
  final VoidCallback onUsar;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final suave = AppColors.onSurface.withValues(alpha: 0.7);
    final descricao = item.descricao;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.large,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImageFrame(imagePath: item.imagem, width: 64, height: 64),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nome,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        [
                          if (item.quantidade > 1) '×${item.quantidade}',
                          '${_kg(item.pesoKg)} kg',
                          if (item.equipado) 'equipado',
                        ].join(' · '),
                        style: textTheme.bodyMedium?.copyWith(color: suave),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (descricao != null) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(
                descricao,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.large),
            Row(
              spacing: AppSpacing.small,
              children: [
                if (item.slotEquipavel != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onEquipar,
                      child: Text(item.equipado ? 'Desequipar' : 'Equipar'),
                    ),
                  ),
                if (item.consumivel)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onUsar,
                      child: const Text('Usar'),
                    ),
                  ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRemover,
                    child: const Text('Remover'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
