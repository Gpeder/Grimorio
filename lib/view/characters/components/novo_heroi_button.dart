import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class NovoHeroiButton extends StatelessWidget {
  const NovoHeroiButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  static const _acimaDaBarra = 110.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _acimaDaBarra),
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: const Icon(Pixel.plus),
        label: const Text('Novo herói'),
      ),
    );
  }
}
