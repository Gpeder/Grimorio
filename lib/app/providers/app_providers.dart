import 'package:flutter/widgets.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // usuario e preferencias
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        // herois
        ChangeNotifierProvider(create: (_) => PersonagensProvider()),
        // campanhas
        ChangeNotifierProvider(create: (_) => CampanhasProvider()),
      ],
      child: child,
    );
  }
}
