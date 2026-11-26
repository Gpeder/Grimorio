import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec nao tem os pacotes que sairam', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final pacote in [
      'flutter_riverpod',
      'drift',
      'drift_flutter',
      'drift_dev',
      'hugeicons',
      'build_runner',
    ]) {
      expect(pubspec, isNot(contains('$pacote:')), reason: pacote);
    }
  });
}
