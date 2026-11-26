import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/personagem.dart';

class GemasMagia extends StatelessWidget {
  const GemasMagia({
    super.key,
    required this.espacos,
    required this.onGastar,
    required this.onRecuperar,
  });

  final List<EspacoMagia> espacos;
  final ValueChanged<int> onGastar;
  final ValueChanged<int> onRecuperar;

  @override
  Widget build(BuildContext context) {
    final ordenados = [...espacos]
      ..sort((a, b) => a.circulo.compareTo(b.circulo));

    return Column(
      children: [
        for (final e in ordenados)
          Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${e.circulo}º',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.small,
                  children: [
                    for (var i = 0; i < e.total; i++)
                      _Gema(
                        key: ValueKey('gema-${e.circulo}-$i'),
                        cheia: i < e.livres,
                        onTap: () => i < e.livres
                            ? onGastar(e.circulo)
                            : onRecuperar(e.circulo),
                      ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Gema extends StatelessWidget {
  const _Gema({super.key, required this.cheia, required this.onTap});

  final bool cheia;
  final VoidCallback onTap;

  static const _area = 30.0;
  static const _lado = 15.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: cheia ? 'Espaço livre' : 'Espaço gasto',
      child: InkResponse(
        onTap: onTap,
        radius: _area / 2,
        child: SizedBox.square(
          dimension: _area,
          child: Center(
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: _lado,
                height: _lado,
                decoration: BoxDecoration(
                  color: cheia ? AppColors.mana : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: cheia
                        ? AppColors.mana
                        : AppColors.mana.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
