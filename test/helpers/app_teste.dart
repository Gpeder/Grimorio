import 'package:flutter/material.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/main.dart';

import 'auth_falso.dart';
import 'dio_falso.dart';
import 'perfil_falso.dart';

// tela solta com os providers do mock, ja logado
Widget telaDeTeste(
  Widget tela, {
  DioFalso? dio,
  AuthServiceFalso? auth,
  PerfilServiceFalso? perfis,
  bool logado = true,
}) => AppProviders(
  api: clienteFalso(dio ?? DioFalso()),
  auth: auth ?? AuthServiceFalso(logado: logado),
  perfis: perfis ?? PerfilServiceFalso(),
  child: MaterialApp(theme: AppTheme.dark, home: tela),
);

// app inteiro aberto numa rota, a api responde pelo dio falso
Widget appDeTeste(
  String rota, {
  DioFalso? dio,
  AuthServiceFalso? auth,
  PerfilServiceFalso? perfis,
  bool logado = true,
}) => GrimorioApp(
  inicial: rota,
  api: clienteFalso(dio ?? DioFalso()),
  auth: auth ?? AuthServiceFalso(logado: logado),
  perfis: perfis ?? PerfilServiceFalso(),
);
