import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ImageBg(imagePath: 'images/bg/bg_1.webp'),
            const SizedBox(height: 16),

            ImageBg(
              imagePath: 'images/bg/castelo.webp',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grimório RPG', style: textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Suas campanhas em um só lugar',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
