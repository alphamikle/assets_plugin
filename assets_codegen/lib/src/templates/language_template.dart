import 'package:assets_codegen/src/constants/common_constants.dart';
import 'package:assets_codegen/src/constants/language_template_constants.dart';
import 'package:yaml/yaml.dart';

void _nullException(String value, [String name = CODE]) {
  if (value == null) {
    throw ArgumentError.notNull(name);
  }
}

void _emptyException(String value, [String name = CODE]) {
  if (value.isEmpty) {
    throw ArgumentError.value(value, name, '$name must not been empty');
  }
}

class LanguageTemplate {
  final String title;

  String _messages = '';

  LanguageTemplate(this.title) : assert(title != null);

  String get _start => '''
    class _$title implements $ABSTRACT_CLASS_NAME {
  ''';

  String get _end => '''
    }
  ''';

  Map<String, String> get methods => _methods;

  Map<String, String> _methods = {};

  void addSimpleMessage(String code, String value, [String desc = '']) {
    _nullException(code, CODE);
    _nullException(value, VALUE);
    _emptyException(code, CODE);

    final String _desc = desc.isNotEmpty ? '/// $desc' : '';

    _messages += '''
    @override
    final String $code = Intl.message('$value', name: '$code'
    ''';
    if (_desc.isNotEmpty) {
      _messages += ', desc: \'$desc\'';
    }
    _messages += ');\n\n';
    _methods[code] = '''
    $_desc
    final String $code = \'\';
    ''';
  }

  void _addPluralMessage(String code, {String zero, String one, String two, String few, String many, String other, String desc}) {
    _nullException(code, CODE);
    _nullException(zero, ZERO);
    _nullException(one, ONE);
    _nullException(other, OTHER);
    _emptyException(code, CODE);

    r(String message) {
      final String pattern = r'%N';
      if (message.contains(pattern)) {
        return message.replaceAll(pattern, '\$$HOW_MANY');
      }
      return '$message';
    }

    final String _desc = desc != null && desc.isNotEmpty ? '/// $desc' : '';

    _messages += '''
    @override
    String $code(int $HOW_MANY) => Intl.plural(howMany, name: '$code', zero: '${r(zero)}', one: '${r(one)}', other: '${r(other)}'
    ''';
    if (two != null && two.isNotEmpty) {
      _messages += ', two: \'${r(two)}\'';
    }
    if (few != null && few.isNotEmpty) {
      _messages += ', few: \'$few\'';
    }
    if (many != null && many.isNotEmpty) {
      _messages += ', many: \'$many\'';
    }
    if (_desc.isNotEmpty) {
      _messages += ', desc: \'$desc\'';
    }
    _messages += ');\n\n';
    _methods[code] = '''
    $_desc
    String $code(int $HOW_MANY) => \'\';
    ''';
  }

  void addMapMessage(String code, YamlMap value) {
    if (value[VALUE] != null) {
      addSimpleMessage(code, value[VALUE], value[DESC] ?? '');
      return;
    }
    if (value[ZERO] != null) {
      _addPluralMessage(code, zero: value[ZERO], one: value[ONE], two: value[TWO], few: value[FEW], many: value[MANY], other: value[OTHER], desc: value[DESC]);
    }
  }

  String get template {
    return _start + _messages + _end;
  }
}
