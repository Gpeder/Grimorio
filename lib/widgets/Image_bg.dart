import 'package:flutter/material.dart';

class ImageBg extends StatelessWidget {
  final String imagePath;
  final double height;
  final Widget? child;

  const ImageBg({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          const ColoredBox(color: Colors.black54),
          if (child != null)
            Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}