import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:assets_annotations/assets_annotations.dart';
import 'package:assets_codegen/src/mixins/directory_watcher.dart';
import 'package:assets_codegen/src/templates/intl_template.dart';
import 'package:assets_codegen/src/templates/language_template.dart';
import 'package:assets_codegen/src/templates/parsing_methods.dart';
import 'package:assets_codegen/src/utils/utils.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

class IntlGenerator extends GeneratorForAnnotation<IntlHelp> with WatcherDisabler<IntlHelp>, DirectoryWatcher<IntlHelp> {
  final Set<String> _intlFiles = {};
  final Set<String> _assetsFiles = {};
  IntlTemplate _intlTemplate;
  Map<String, LanguageTemplate> _languages = {};

  String _intlFilesPrefix;

  IntlGenerator(BuilderOptions options) {
    scanAssets();
    final Map<String, dynamic> config = options.config;
    withWatchers = config['once'] != true;
    if (!withWatchers) {
      print('IntlGenerator will start without files watcher');
    }
  }

  bool isIntlFile(String fileName) => fileName.contains(RegExp('$_intlFilesPrefix\.ya?ml\$'));

  void _fillIntlFiles() {
    _intlFiles.clear();
    _assetsFiles.clear();
    _assetsFiles.addAll(getAssetDirectoryFiles());
    for (String assetFile in _assetsFiles) {
      if (isIntlFile(assetFile)) {
        _intlFiles.add(assetFile);
      }
    }
  }

  String _getLanguageCode(String originalFileName) {
    final RegExp regExp = RegExp('\/([a-z]+)\/?\.?($_intlFilesPrefix).ya?ml\$');
    final RegExpMatch match = regExp.firstMatch(originalFileName);
    if (match == null) {
      return 'en';
    }
    return match.group(1);
  }

  void _readIntlFiles() {
    _languages.clear();
    bool isFirst = true;
    for (String intlFile in _intlFiles) {
      final File file = File(p.join(path, intlFile));
      YamlMap fileContent = loadYaml(file.readAsStringSync());
      List<MapEntry<dynamic, dynamic>> entries = fileContent.entries.toList();
      final String languageCode = _getLanguageCode(intlFile);
      final LanguageTemplate languageTemplate = LanguageTemplate(capitalize(languageCode), isFirst);
      for (MapEntry<dynamic, dynamic> entry in entries) {
        _writeMessage(entry, languageTemplate);
      }
      _languages[languageCode] = languageTemplate;
      _intlTemplate.addLanguage(languageCode, languageTemplate);
      isFirst = false;
    }
  }

  void _writeMessage(MapEntry<dynamic, dynamic> entry, LanguageTemplate template) {
    final String code = entry.key as String;
    final dynamic value = entry.value;
    addMessageToLocalizationContentTemplate(value, code, template);
  }

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    _intlTemplate = IntlTemplate(element.name);
    _intlFilesPrefix = annotation.read('prefix').stringValue;
    _fillIntlFiles();
    _readIntlFiles();
    tryToAssignWatchers(element, annotation, buildStep);
    return _intlTemplate.template;
  }
}
