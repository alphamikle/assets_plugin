import 'dart:io';

import 'package:yaml/yaml.dart';

const FLUTTER = 'flutter';
const ASSETS = 'assets';

class AssetsScanner {
  Directory _curDir;
  String _path;
  List<FileSystemEntity> _files;
  FileSystemEntity _pubspecEntity;
  File _pubspecFile;
  YamlMap _pubspecContent;
  YamlMap _flutter;
  YamlList _assetsFolders;

  String get path => _path;

  YamlList get assetsFolders => _assetsFolders;

  AssetsScanner() {
    _curDir = Directory.current;
    _path = _curDir.path;
    _files = _curDir.listSync();
    _pubspecEntity = _files.firstWhere((FileSystemEntity fileEntity) => fileEntity.path.contains(RegExp(r'pubspec.ya?ml$')),
        orElse: () => _exception('pubspec file'));
    _pubspecFile = File(_pubspecEntity.path);
    _pubspecContent = loadYaml(_pubspecFile.readAsStringSync());
    _flutter = _pubspecContent[FLUTTER];
    if (_flutter == null) {
      _exception('"flutter" section in pubspec');
    }
    _assetsFolders = _flutter[ASSETS];
  }

  _exception(String what) {
    throw Exception('Not found $what in $_path directory');
  }
}
