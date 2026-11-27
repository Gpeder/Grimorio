import 'package:flutter/material.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/main.dart';

import 'auth_falso.dart';
import 'banco_falso.dart';
import 'dio_falso.dart';
import 'perfil_falso.dart';

// o banco falso enxerga como quem esta logado no auth falso
BancoFalso _banco(BancoFalso? banco, AuthServiceFalso auth) =>
    banco ?? BancoFalso(usuario: () => auth.usuarioId ?? '');

// tela solta com os providers e o banco falso, ja logado
Widget telaDeTeste(
  Widget tela, {
  DioFalso? dio,
  AuthServiceFalso? auth,
  PerfilServiceFalso? perfis,
  BancoFalso? banco,
  bool logado = true,
}) {
  final a = auth ?? AuthServiceFalso(logado: logado);
  return AppProviders(
    api: clienteFalso(dio ?? DioFalso()),
    auth: a,
    perfis: perfis ?? PerfilServiceFalso(),
    banco: _banco(banco, a).servicos,
    child: MaterialApp(theme: AppTheme.dark, home: tela),
  );
}

// app inteiro aberto numa rota, a api responde pelo dio falso
Widget appDeTeste(
  String rota, {
  DioFalso? dio,
  AuthServiceFalso? auth,
  PerfilServiceFalso? perfis,
  BancoFalso? banco,
  bool logado = true,
}) {
  final a = auth ?? AuthServiceFalso(logado: logado);
  return GrimorioApp(
    inicial: rota,
    api: clienteFalso(dio ?? DioFalso()),
    auth: a,
    perfis: perfis ?? PerfilServiceFalso(),
    banco: _banco(banco, a).servicos,
  );
}
