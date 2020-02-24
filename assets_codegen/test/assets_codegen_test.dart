import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('directory scanner', () async {
    final Directory dir = Directory('dir');
    print(dir);
  });
}
