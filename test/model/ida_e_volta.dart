import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

// passa pelo texto json como se viesse do banco
Map<String, dynamic> pelaRede(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void confereIdaEVolta<T>(
  T x,
  Map<String, dynamic> Function(T) toJson,
  T Function(Map<String, dynamic>) fromJson,
) {
  final json = toJson(x);
  expect(toJson(fromJson(pelaRede(json))), equals(pelaRede(json)));
}
