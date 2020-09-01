import 'dart:async';

import 'package:analyzer/dart/element/element.dart' as el;
import 'package:assets_annotations/assets_annotations.dart';
import 'package:assets_codegen/src/mixins/directory_watcher.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

const ASSET_ENUM = 'Asset';
const ASSET_ENUM_MAP = '_assetEnumMap';

/// Generator for user classes, annotated with @AstHelp
class AssetsGenerator extends GeneratorForAnnotation<AstHelp> with WatcherDisabler<AstHelp>, DirectoryWatcher<AstHelp> {
  final Set<String> _assetsFiles = {};
  final Set<String> _assetsFields = {};

  Set<String> _preloadMimes = {};

  AssetsGenerator(BuilderOptions options) {
    scanAssets();
    final Map<String, dynamic> config = options.config;
    withWatchers = config['once'] != true;
    if (!withWatchers) {
      print('AssetsGenerator will start without files watcher');
    }
    if (config['default_preload'] == null) {
      throw Exception('Not found "default_preload" field in build.yaml file');
    }
    for (String defaultPreloadMime in config['default_preload']) {
      _preloadMimes.add(defaultPreloadMime);
    }
    if (config['preload'] != null) {
      for (String preloadMime in config['preload']) {
        _preloadMimes.add(preloadMime);
      }
    }
  }

  /// Returns assets mixin start
  String _startMixin(String title) {
    return 'mixin _\$$title {\n';
  }

  String _replaceSlash(String assetField) {
    return assetField.replaceAll('/', '_').replaceAll(' ', '_');
  }

  String _replaceDash(String assetField) {
    return assetField.replaceAll('-', '_');
  }

  String _replaceExtension(String assetField) {
    return assetField.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
  }

  String _replaceUnderscore(String assetField) {
    assetField = assetField.replaceAllMapped(RegExp(r'_([a-zA-Z0-9])'), (Match match) => match.group(1).toUpperCase()).replaceAll('_', '');
    return assetField.replaceAllMapped(RegExp(r'^([A-Z])'), (Match match) => match.group(1).toLowerCase());
  }

  /// Replace invalid dart variable names for correct with prefix asset...
  String _checkForInvalidFieldName(String assetField) {
    if (!assetField.contains(RegExp(r'^[a-z_$]'))) {
      assetField = 'asset$assetField';
    }
    return assetField;
  }

  /// Check for same file name in several files in different dirs
  String _checkForCopy(String assetField, String assetFileName) {
    if (_assetsFields.contains(assetField) && !_assetsFiles.contains(assetFileName)) {
      assetField += 'Copy';
      return _checkForCopy(assetField, assetFileName);
    }
    return assetField;
  }

  /// Add an asset mixin field with an asset full path and short name
  String _addAssetClassField(String assetFileName) {
    String assetField = getOnlyAssetFileName(assetFileName);
    assetField = _replaceSlash(assetField);
    assetField = _replaceDash(assetField);
    assetField = _replaceExtension(assetField);
    assetField = _replaceUnderscore(assetField);
    assetField = _checkForInvalidFieldName(assetField);
    assetField = _checkForCopy(assetField, assetFileName);
    _assetsFields.add(assetField);
    _assetsFiles.add(assetFileName);
    return 'final $assetField = \'$assetFileName\';\n';
  }

  String _startEnum() {
    return '''enum $ASSET_ENUM {
      _stub,
    ''';
  }

  String _addToEnum(String assetField) {
    final String fieldName = RegExp(r'^final ([a-zA-Z0-9]+) =').firstMatch(assetField).group(1);
    return '$fieldName,\n';
  }

  String _closeEnum(String assetEnum) {
    return '$assetEnum\n}\n';
  }

  String _startEnumMap() {
    return '\nfinal Map<$ASSET_ENUM, String> $ASSET_ENUM_MAP = {\n';
  }

  String _addToEnumMap(String enumField, String assetFileName) {
    final String fieldName = RegExp(r'^([a-zA-Z0-9]+)').firstMatch(enumField).group(1);
    return '$ASSET_ENUM.$fieldName: \'$assetFileName\',\n';
  }

  String _closeEnumMap(String enumMap) {
    return '$enumMap\n};\n\n';
  }

  /// Generate preload assets function
  String _preloadAssets() {
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
      await Future.wait<void>(loaders);
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

  String _endMixin(String mixin) {
    return '$mixin\n}';
  }

  @override
  FutureOr<String> generateForAnnotatedElement(el.Element element, ConstantReader annotation, BuildStep step) async {
    String assetsHelperMixin = _startMixin(element.name);
    final Set<String> tempAssetsFiles = getAssetDirectoryFiles();
    String assetEnum = _startEnum();
    String enumMap = _startEnumMap();
    for (String assetFile in tempAssetsFiles) {
      final String fieldName = _addAssetClassField(assetFile);
      if (_preloadMimes.any((String mime) => assetFile.contains(RegExp('\.$mime\$')))) {
        final String enumField = _addToEnum(fieldName);
        assetEnum += enumField;
        enumMap += _addToEnumMap(enumField, assetFile);
      }
      assetsHelperMixin += fieldName;
    }
    enumMap = _closeEnumMap(enumMap);
    assetEnum = _closeEnum(assetEnum);
    assetsHelperMixin += _preloadAssets();
    if (_assetsFiles.isEmpty) {
      assetsHelperMixin += '// Not found any asset file in assets folder';
    }
    assetsHelperMixin = _endMixin(assetsHelperMixin);
    assetsHelperMixin = assetEnum + enumMap + assetsHelperMixin;
    _assetsFiles.clear();
    _assetsFields.clear();
    tryToAssignWatchers(element, annotation, step);
    return assetsHelperMixin;
  }
}
