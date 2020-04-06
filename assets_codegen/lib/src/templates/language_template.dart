import 'package:assets_codegen/src/constants/common_constants.dart';
import 'package:assets_codegen/src/constants/language_template_constants.dart';
import 'package:edit_distance/edit_distance.dart' show Levenshtein;
import 'package:yaml/yaml.dart';

void _nullException(String value, [String name = 'code']) {
  if (value == null) {
    throw ArgumentError.notNull(name);
  }
}

void _emptyException(String value, [String name = CODE]) {
  if (value.isEmpty) {
    throw ArgumentError.value(value, name, '$name must not been empty');
  }
}

bool _isLastItemIsOther(List<String> zeroOneTwoOrOther, String otherOrDesc) {
  final Levenshtein comparator = Levenshtein();
  otherOrDesc = otherOrDesc.toLowerCase();
  double maxDiff = 0;
  double otherDiff = double.infinity;
  final int otherCounter = zeroOneTwoOrOther.length;
  for (int i = 0; i < otherCounter; i++) {
    final String value = zeroOneTwoOrOther[i].toLowerCase();
    for (int k = i + 1; k < otherCounter; k++) {
      final String otherValue = zeroOneTwoOrOther[k].toLowerCase();
      final double similarity = comparator.distance(value, otherValue).toDouble();
      if (similarity > maxDiff) {
        maxDiff = similarity;
      }
    }
    final double similarity = comparator.distance(value, otherOrDesc).toDouble();
    if (similarity < otherDiff) {
      otherDiff = similarity;
    }
  }
  print('$maxDiff, $otherDiff, $zeroOneTwoOrOther, $otherOrDesc');
  return !(maxDiff >= otherDiff);
}

class LanguageTemplate {
  final String title;

  String _messages = '';

  LanguageTemplate(this.title) : assert(title != null);

  String get _start => '''
    class _$title extends $ABSTRACT_CLASS_NAME {
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

  void _addPluralMessage(String code, {String zero, String one, String two, String other, String desc}) {
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
      return '\$$HOW_MANY $message';
    }

    final String _desc = desc != null && desc.isNotEmpty ? '/// $desc' : '';

    _messages += '''
    @override
    String $code(int $HOW_MANY) => Intl.plural(howMany, name: '$code', zero: '${r(zero)}', one: '${r(one)}', other: '${r(other)}'
    ''';
    if (two != null && two.isNotEmpty) {
      _messages += ', two: \'${r(two)}\'';
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
      _addPluralMessage(code, zero: value[ZERO], one: value[ONE], two: value[TWO], other: value[OTHER], desc: value[DESC]);
    }
  }

  void addListMessage(String code, YamlList value) {
    switch (value.length) {
      case ALL_WITH_DESC:
        {
          _addPluralMessage(code,
              zero: value[ZERO_NUM_ALL],
              one: value[ONE_NUM_ALL],
              two: value[TWO_NUM_ALL],
              other: value[OTHER_NUM_ALL],
              desc: value[DESC_NUM_ALL] ?? '');
          return;
        }
      case ALL_WITHOUT_DESC_OR_WITHOUT_TWO_WITH_DESC:
        {
          if (_isLastItemIsOther([value[ZERO_NUM_NOT_ALL], value[ONE_NUM_NOT_ALL], value[OTHER_NUM_NOT_ALL]], value[DESC_NUM_NOT_ALL])) {
            _addPluralMessage(code,
                zero: value[ZERO_NUM_NOT_ALL], one: value[ONE_NUM_NOT_ALL], other: value[OTHER_NUM_NOT_ALL], desc: value[DESC_NUM_NOT_ALL] ?? '');
            return;
          }
          _addPluralMessage(code, zero: value[ZERO_NUM_ALL], one: value[ONE_NUM_ALL], two: value[TWO_NUM_ALL], other: value[OTHER_NUM_ALL]);
          return;
        }
      case WITHOUT_TWO_WITHOUT_DESC:
        {
          _addPluralMessage(code, zero: value[ZERO_NUM_NOT_ALL], one: value[ONE_NUM_NOT_ALL], other: value[OTHER_NUM_NOT_ALL]);
          return;
        }
      case VALUE_WITH_DESC:
        {
          addSimpleMessage(code, value[VALUE_NUM], value[DESC_NUM] ?? '');
          return;
        }
      case VALUE_WITHOUT_DESC:
        {
          addSimpleMessage(code, value[VALUE_NUM]);
          return;
        }
      default:
        {
          throw ArgumentError.value(value, VALUE, 'Invalid type of value was passed to "addListMessage" method');
        }
    }
  }

  String get template {
    return _start + _messages + _end;
  }
}
