import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

// header, formulario e rodape no fim da tela; rola com o teclado aberto
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.header,
    required this.children,
    this.rodape,
  });

  final Widget header;
  final List<Widget> children;
  final Widget? rodape;

  static const _larguraMaxima = 480.0;

  Widget _limitado(Widget child) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _larguraMaxima),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final rodape = this.rodape;
    final baixo = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          SliverToBoxAdapter(
            child: _limitado(
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large + baixo,
                ),
                child: rodape == null ? null : _limitado(rodape),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
