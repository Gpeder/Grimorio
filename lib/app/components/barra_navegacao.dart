import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static const indiceCentral = 2;
  static const _ladoBotao = 54.0;
  static const _sobe = 26.0;

  static const temaBotaoCentral = BottomBarCenterActionThemeData(
    size: _ladoBotao,
    raise: _sobe,
    elevation: 0,
  );

  static const itens = <(IconData, String)>[
    (Pixel.home, 'Início'),
    (Pixel.users, 'Heróis'),
    (Pixel.map, 'Campanhas'),
    (Pixel.bookopen, 'Grimório'),
    (Pixel.settingscog, 'Ajustes'),
  ];

  void _tocar(int i) {
    HapticFeedback.selectionClick();
    onSelected(i);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < itens.length; i++)
          Expanded(
            child: i == indiceCentral
                ? _ItemCentral(
                    icone: itens[i].$1,
                    label: itens[i].$2,
                    ativo: selectedIndex == i,
                    onTap: () => _tocar(i),
                  )
                : _Item(
                    icone: itens[i].$1,
                    label: itens[i].$2,
                    ativo: selectedIndex == i,
                    onTap: () => _tocar(i),
                  ),
          ),
      ],
    );
  }
}

const _duracao = Duration(milliseconds: 200);
const _raioPill = BorderRadius.all(Radius.circular(AppSpacing.radiusSmall));

TextStyle? _estiloLabel(
  BuildContext context, {
  required Color cor,
  bool forte = false,
}) {
  return Theme.of(context).textTheme.labelSmall?.copyWith(
    color: cor,
    fontWeight: forte ? FontWeight.bold : FontWeight.w600,
  );
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = ativo
        ? AppColors.alerta
        : AppColors.onSurface.withValues(alpha: 0.6);

    return Semantics(
      button: true,
      selected: ativo,
      child: InkWell(
        onTap: onTap,
        borderRadius: _raioPill,
        child: AnimatedContainer(
          duration: _duracao,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: ativo
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.transparent,
            borderRadius: _raioPill,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 24, color: cor),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _estiloLabel(context, cor: cor, forte: ativo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCentral extends StatelessWidget {
  const _ItemCentral({
    required this.icone,
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomBarCenterAction(
          style: BottomBarCenterActionStyle.raised,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radius)),
          ),
          semanticLabel: label,
          onPressed: onTap,
          icon: _BotaoCentral(icone: icone, ativo: ativo),
        ),
        ExcludeSemantics(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _estiloLabel(
                  context,
                  cor: ativo ? AppColors.alerta : AppColors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoCentral extends StatelessWidget {
  const _BotaoCentral({required this.icone, required this.ativo});

  final IconData icone;
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duracao,
      width: BarraNavegacao._ladoBotao,
      height: BarraNavegacao._ladoBotao,
      decoration: BoxDecoration(
        color: ativo ? AppColors.alerta : AppColors.primary,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSpacing.radius),
        ),
        border: Border.all(color: AppColors.alerta, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icone,
        size: 26,
        color: ativo ? AppColors.background : AppColors.onSurface,
      ),
    );
  }
}
