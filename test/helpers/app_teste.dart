import 'package:flutter/material.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/main.dart';

import 'dio_falso.dart';

// tela solta com os providers do mock
Widget telaDeTeste(Widget tela, {DioFalso? dio}) => AppProviders(
  api: clienteFalso(dio ?? DioFalso()),
  child: MaterialApp(theme: AppTheme.dark, home: tela),
);

// app inteiro aberto numa rota, a api responde pelo dio falso
Widget appDeTeste(String rota, {DioFalso? dio}) =>
    GrimorioApp(inicial: rota, api: clienteFalso(dio ?? DioFalso()));
