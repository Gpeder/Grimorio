import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/widgets/avatar_circle.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? avatarPath;

  const HomeAppbar({super.key, this.avatarPath = AppImages.especie13});

  static const _height = 90.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      toolbarHeight: _height,
      leadingWidth: 100,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(child: AvatarCircle(imagePath: avatarPath, radius: 30)),
      ),
      title: Image.asset(AppImages.logo, height: 80, fit: BoxFit.contain),
    );
  }
}
