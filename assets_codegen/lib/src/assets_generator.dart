import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart' as el;
import 'package:assets_annotations/assets_annotations.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

const ASSETS = 'assets';
const FLUTTER = 'flutter';
const ASSET_ENUM = 'Asset';
const ASSET_ENUM_MAP = '_assetEnumMap';

/// Generator for user classes, annotated with @AstHelp
class AssetsGenerator extends GeneratorForAnnotation<AstHelp> {
  Directory curDir;
  String path;
  List<FileSystemEntity> files;
  FileSystemEntity pubspecEntity;
  File pubspecFile;
  YamlMap pubspecContent;
  YamlMap flutter;
  YamlList assetsFolders;
  final Set<String> assetsFiles = {};
  final Set<String> assetsFields = {};
  final Map<String, Stream<FileSystemEvent>> assetsFoldersWatchers = {};
  bool isWatchersAssigned = false;
  String generatedFilePath;
  el.Element prevElement;
  ConstantReader prevAnnotation;
  BuildStep prevStep;
  Set<String> preloadMimes = {};

  AssetsGenerator(BuilderOptions options) {
    exception(String what) {
      throw Exception('Not found $what in $path directory');
    }

    final Map<String, dynamic> config = options.config;
    if (config['default_preload'] == null) {
      throw Exception('Not found "default_preload" field in build.yaml file');
    }
    for (String defaultPreloadMime in config['default_preload']) {
      preloadMimes.add(defaultPreloadMime);
    }
    if (config['preload'] != null) {
      for (String preloadMime in config['preload']) {
        preloadMimes.add(preloadMime);
      }
    }
    curDir = Directory.current;
    path = curDir.path;
    files = curDir.listSync();
    pubspecEntity = files.firstWhere(
        (FileSystemEntity fileEntity) =>
            fileEntity.path.contains(RegExp(r'pubspec.ya?ml$')),
        orElse: () => exception('pubspec file'));
    pubspecFile = File(pubspecEntity.path);
    pubspecContent = loadYaml(pubspecFile.readAsStringSync());
    flutter = pubspecContent[FLUTTER];
    if (flutter == null) {
      exception('"flutter" section in pubspec');
    }
    assetsFolders = flutter[ASSETS];
  }

  /// Return generated file header
  String getHead(String generatedFileName) {
    return '''
      // GENERATED CODE - DO NOT MODIFY BY HAND

      part of '$generatedFileName.dart';

      // **************************************************************************
      // AssetsGenerator
      // **************************************************************************

    ''';
  }

  /// Watcher for assets directories changes
  void directoryWatcher() {
    final DartFormatter formatter = DartFormatter();
    String manualGeneratedFileName = replaceAssetFolder(prevStep.inputId.path)
        .replaceAll(RegExp(r'\.dart$'), '');
    String manualGeneratedFilePath = p.join(
        Directory.current.path,
        prevStep.inputId.path.replaceFirst('$manualGeneratedFileName.dart',
            '$manualGeneratedFileName.g.dart'));
    String manualGeneratedCode = formatter.format(
        getHead(manualGeneratedFileName) +
            generateForAnnotatedElement(prevElement, prevAnnotation, prevStep));
    final File generatedFile = File(manualGeneratedFilePath);
    generatedFile.writeAsString(manualGeneratedCode);
  }

  /// Add watcher function for folders watchers
  void assignWatchers() {
    assetsFoldersWatchers.forEach((String key, Stream<FileSystemEvent> value) {
      value.listen((FileSystemEvent event) {
        if ((event is FileSystemCreateEvent ||
                event is FileSystemDeleteEvent) &&
            !event.path.contains('___jb_tmp___')) {
          directoryWatcher();
        }
      });
    });
    isWatchersAssigned = true;
  }

  /// Returns assets mixin start
  String startMixin(String title) {
    return 'mixin _\$$title {\n';
  }

  String replaceAssetFolder(String assetFileName) {
    assetFileName = assetFileName.replaceAll(RegExp(r'^.*\/'), '');
    return assetFileName;
  }

  String replaceSlash(String assetField) {
    return assetField.replaceAll('/', '_').replaceAll(' ', '_');
  }

  String replaceDash(String assetField) {
    return assetField.replaceAll('-', '_');
  }

  String replaceExtension(String assetField) {
    return assetField.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
  }

  String replaceUnderscore(String assetField) {
    assetField = assetField
        .replaceAllMapped(RegExp(r'_([a-zA-Z0-9])'),
            (Match match) => match.group(1).toUpperCase())
        .replaceAll('_', '');
    return assetField.replaceAllMapped(
        RegExp(r'^([A-Z])'), (Match match) => match.group(1).toLowerCase());
  }

  /// Replace invalid dart variable names for correct with prefix asset...
  String checkForInvalidFieldName(String assetField) {
    if (!assetField.contains(RegExp(r'^[a-z_$]'))) {
      assetField = 'asset$assetField';
    }
    return assetField;
  }

  /// Check for same file name in several files in different dirs
  String checkForCopy(String assetField, String assetFileName) {
    if (assetsFields.contains(assetField) &&
        !assetsFiles.contains(assetFileName)) {
      assetField += 'Copy';
      return checkForCopy(assetField, assetFileName);
    }
    return assetField;
  }

  /// Add an asset mixin field with an asset full path and short name
  String addAssetClassField(String assetFileName) {
    String assetField = replaceAssetFolder(assetFileName);
    assetField = replaceSlash(assetField);
    assetField = replaceDash(assetField);
    assetField = replaceExtension(assetField);
    assetField = replaceUnderscore(assetField);
    assetField = checkForInvalidFieldName(assetField);
    assetField = checkForCopy(assetField, assetFileName);
    assetsFields.add(assetField);
    assetsFiles.add(assetFileName);
    return 'final $assetField = \'$assetFileName\';\n';
  }

  String startEnum() {
    return 'enum $ASSET_ENUM {\n';
  }

  String addToEnum(String assetField) {
    final String fieldName =
        RegExp(r'^final ([a-zA-Z0-9]+) =').firstMatch(assetField).group(1);
    return '$fieldName,\n';
  }

  String closeEnum(String assetEnum) {
    return '$assetEnum\n}\n';
  }

  String startEnumMap() {
    return '\nfinal Map<$ASSET_ENUM, String> $ASSET_ENUM_MAP = {\n';
  }

  String addToEnumMap(String enumField, String assetFileName) {
    final String fieldName =
        RegExp(r'^([a-zA-Z0-9]+)').firstMatch(enumField).group(1);
    return '$ASSET_ENUM.$fieldName: \'$assetFileName\',\n';
  }

  String closeEnumMap(String enumMap) {
    return '$enumMap\n};\n\n';
  }

  /// Generate preload assets function
  String preloadAssets() {
    return '''
    final Map<$ASSET_ENUM, String> _preloadedAssets = Map();
    bool isPreloaded = false;
    Future<bool> preloadAssets() async {
      final List<Future> loaders = [];
      loadAsset($ASSET_ENUM asset) async {        
        final String assetContent = await rootBundle.loadString($ASSET_ENUM_MAP[asset], cache: false);
        _preloadedAssets[asset] = assetContent;
      }
      for ($ASSET_ENUM assetEnumField in $ASSET_ENUM.values) {
        loaders.add(loadAsset(assetEnumField));
      }
      await Future.wait(loaders);
      isPreloaded = true;
      return isPreloaded;
    }
    String getAssetData($ASSET_ENUM assetEnum) {
      if (!isPreloaded) {
        throw Exception('You should run method "preloadAssets" before accessing data with "getAssetData" method');
      }
      return _preloadedAssets[assetEnum];
    }''';
  }

  String endMixin(String mixin) {
    return '$mixin\n}';
  }

  @override
  FutureOr<String> generateForAnnotatedElement(
      el.Element element, ConstantReader annotation, BuildStep step) {
    String mixin = startMixin(element.name);
    final Set<String> tempAssetsFiles = {};
    for (String assetFolder in assetsFolders) {
      final String dirPath = p.join(path, assetFolder);
      final Directory assetDirectory = Directory(dirPath);
      if (!assetsFoldersWatchers.containsKey(dirPath)) {
        assetsFoldersWatchers[dirPath] = assetDirectory.watch(recursive: true);
      }
      final List<FileSystemEntity> folderFiles = assetDirectory
          .listSync(recursive: true)
          .where((FileSystemEntity fileEntity) =>
              FileSystemEntity.isFileSync(fileEntity.path))
          .toList();
      tempAssetsFiles.addAll(folderFiles.map((FileSystemEntity fileEntity) =>
          fileEntity.path.replaceFirst(RegExp('$path/'), '')));
    }
    String assetEnum = startEnum();
    String enumMap = startEnumMap();
    for (String assetFile in tempAssetsFiles) {
      final String fieldName = addAssetClassField(assetFile);
      if (preloadMimes
          .any((String mime) => assetFile.contains(RegExp('\.$mime\$')))) {
        final String enumField = addToEnum(fieldName);
        assetEnum += enumField;
        enumMap += addToEnumMap(enumField, assetFile);
      }
      mixin += fieldName;
    }
    enumMap = closeEnumMap(enumMap);
    assetEnum = closeEnum(assetEnum);
    mixin += preloadAssets();
    if (assetsFiles.isEmpty) {
      mixin += '// Not found any asset file in assets folder';
    }
    mixin = endMixin(mixin);
    mixin = assetEnum + enumMap + mixin;
    assetsFiles.clear();
    assetsFields.clear();
    if (!isWatchersAssigned) {
      assignWatchers();
      prevElement = element;
      prevAnnotation = annotation;
      prevStep = step;
    }
    return mixin;
  }
}
