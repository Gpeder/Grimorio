import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/widgets/image_bg.dart';
import 'package:grimorio/widgets/avatar_circle.dart';

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({
    super.key,
    this.avatarPath = AppImages.especieTieflingM,
    this.imagePath = AppImages.bg,
  });

  final String? avatarPath;
  final String imagePath;
  static const _alturaAberta = 200.0;
  static const _alturaFechada = 64.0;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: _alturaAberta,
      toolbarHeight: _alturaFechada,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      flexibleSpace: _ConteudoDaBarra(
        avatarPath: avatarPath,
        imagePath: imagePath,
      ),
    );
  }
}

class _Saudacao extends StatelessWidget {
  const _Saudacao();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Bem vindo de volta!',
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.alerta,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Aventureiro!',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.alerta,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ConteudoDaBarra extends StatelessWidget {
  const _ConteudoDaBarra({required this.avatarPath, required this.imagePath});

  final String? avatarPath;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final medidas = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
    final quantoEncolheu = medidas.maxExtent - medidas.currentExtent;
    final quantoPodeEncolher = medidas.maxExtent - medidas.minExtent;
    final t = (quantoEncolheu / quantoPodeEncolher).clamp(0.0, 1.0);
    final alturaDoTopo = lerpDouble(90, 64, t)!;
    final raioDoAvatar = lerpDouble(30, 20, t)!;
    final alturaDaLogo = lerpDouble(80, 44, t)!;
    final alturaDaBarraDeStatus = MediaQuery.paddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: medidas.maxExtent,
          child: Opacity(
            opacity: 1 - t,
            child: ImageBg(
              imagePath: imagePath,
              height: medidas.maxExtent,
              child: const _Saudacao(),
            ),
          ),
        ),

        Positioned(
          top: alturaDaBarraDeStatus,
          left: 0,
          right: 0,
          height: alturaDoTopo,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: AvatarCircle(
                    imagePath: avatarPath,
                    radius: raioDoAvatar,
                  ),
                ),
              ),
              // Logo no centro.
              Center(
                child: Image.asset(
                  AppImages.logo,
                  height: alturaDaLogo,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
