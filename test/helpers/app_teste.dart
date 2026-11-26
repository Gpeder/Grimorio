import 'package:flutter/material.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/main.dart';

// tela solta com os providers do mock
Widget telaDeTeste(Widget tela) => AppProviders(
  child: MaterialApp(theme: AppTheme.dark, home: tela),
);

// app inteiro aberto numa rota
Widget appDeTeste(String rota) => GrimorioApp(inicial: rota);
