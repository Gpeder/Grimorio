import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

const abasFicha = [
  'Resumo',
  'Perícias',
  'Combate',
  'Magias',
  'Inventário',
  'Diário',
];

 Barra de abas que fica presa no topo ao rolar. É um sliver.
class FichaAbas extends StatelessWidget {
  const FichaAbas({super.key, required this.aba, required this.onAba});

  final int aba;
  final ValueChanged<int> onAba;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(aba: aba, onAba: onAba),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  _Delegate({required this.aba, required this.onAba});

  final int aba;
  final ValueChanged<int> onAba;

  static const _altura = 48.0;

  @override
  double get minExtent => _altura;

  @override
  double get maxExtent => _altura;

  @override
  bool shouldRebuild(_Delegate old) => old.aba != aba || old.onAba != onAba;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
        child: Row(
          children: [
            for (var i = 0; i < abasFicha.length; i++)
              InkWell(
                onTap: () => onAba(i),
                child: Container(
                  height: _altura,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium - 4,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == aba ? AppColors.alerta : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    abasFicha[i],
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: i == aba
                          ? AppColors.onSurface
                          : AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
