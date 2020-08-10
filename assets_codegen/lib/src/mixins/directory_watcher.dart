import 'dart:io';

import 'package:analyzer/dart/element/element.dart' as el;
import 'package:assets_codegen/src/utils/assets_scanner.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

mixin DirectoryWatcher<T> on GeneratorForAnnotation<T> {
  final Map<String, Stream<FileSystemEvent>> _assetsFoldersWatchers = {};

  BuildStep prevStep;
  el.Element prevElement;
  ConstantReader prevAnnotation;
  bool isWatchersAssigned = false;
  String path;
  YamlList _assetsFolders;

  final RegExp _diskWord = RegExp(r'^[a-zA-Z]+:');

  String getOnlyAssetFileName(String assetFileNameWithPath) {
    assetFileNameWithPath = assetFileNameWithPath.replaceAll(RegExp(r'\\'), '/');
    assetFileNameWithPath = assetFileNameWithPath.replaceAll(RegExp(r'^.*\/'), '');
    return assetFileNameWithPath;
  }

  void scanAssets() {
    final AssetsScanner scanner = AssetsScanner();
    path = scanner.path;
    _assetsFolders = scanner.assetsFolders;
  }

  /// Return generated file header
  String getHead(String generatedFileName) {
    return '''
      // GENERATED CODE - DO NOT MODIFY BY HAND

      part of '$generatedFileName.dart';

      // **************************************************************************
      // Generator of $generatedFileName
      // **************************************************************************

    ''';
  }

  Set<String> getAssetDirectoryFiles() {
    final Set<String> tempAssetsFiles = {};
    for (String assetFolder in _assetsFolders) {
      final String dirPath = p.join(path, assetFolder);
      final Directory assetDirectory = Directory(dirPath);
      if (!_assetsFoldersWatchers.containsKey(dirPath)) {
        _assetsFoldersWatchers[dirPath] = assetDirectory.watch(recursive: true);
      }
      final List<FileSystemEntity> folderFiles = assetDirectory.listSync(recursive: true).where((FileSystemEntity fileEntity) => FileSystemEntity.isFileSync(fileEntity.path)).toList();
      final String unixPath = path.replaceFirst(_diskWord, '').replaceAll(r'\', '/');
      tempAssetsFiles.addAll(folderFiles.map((FileSystemEntity fileEntity) {
        final String unixFilePath = fileEntity.path.replaceFirst(_diskWord, '').replaceAll(r'\', '/');
        final result = unixFilePath.replaceFirst(RegExp('$unixPath/'), '');
        return result;
      }).where((String fileName) => !fileName.contains('/.')));
    }
    return tempAssetsFiles;
  }

  /// Watcher for assets directories changes
  void _directoryWatcher() {
    final DartFormatter formatter = DartFormatter();
    String manualGeneratedFileName = getOnlyAssetFileName(prevStep.inputId.path).replaceAll(RegExp(r'\.dart$'), '');
    String manualGeneratedFilePath = p.join(Directory.current.path, prevStep.inputId.path.replaceFirst('$manualGeneratedFileName.dart', '$manualGeneratedFileName.g.dart'));
    String manualGeneratedCode = formatter.format(getHead(manualGeneratedFileName) + generateForAnnotatedElement(prevElement, prevAnnotation, prevStep));
    final File generatedFile = File(manualGeneratedFilePath);
    generatedFile.writeAsStringSync(manualGeneratedCode);
  }

  /// Add watcher function for folders watchers
  void _assignWatchers() {
    _assetsFoldersWatchers.forEach((String key, Stream<FileSystemEvent> value) {
      value.listen((FileSystemEvent event) {
        if ((event is FileSystemCreateEvent || event is FileSystemDeleteEvent) && !event.path.contains('___jb_tmp___')) {
          _directoryWatcher();
        }
      });
    });
    isWatchersAssigned = true;
  }

  void tryToAssignWatchers(el.Element element, ConstantReader annotation, BuildStep step) {
    if (!isWatchersAssigned) {
      _assignWatchers();
      prevElement = element;
      prevAnnotation = annotation;
      prevStep = step;
    }
  }
}
