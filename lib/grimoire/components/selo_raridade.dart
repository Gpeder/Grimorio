import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/models/grimoire.dart';

class SeloRaridade extends StatelessWidget {
  const SeloRaridade(this.raridade, {super.key});

  final Raridade raridade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: raridade.cor),
      ),
      child: Text(
        raridade.nome,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: raridade.cor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
