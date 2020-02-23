import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('directory scanner', () async {
    final Directory dir = Directory('dir');
    print(dir);
  });
}
