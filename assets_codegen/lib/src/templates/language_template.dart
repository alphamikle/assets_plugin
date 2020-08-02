import 'package:assets_codegen/src/constants/common_constants.dart';
import 'package:assets_codegen/src/templates/localization_content_template.dart';

class LanguageTemplate extends LocalizationContentTemplate {
  LanguageTemplate(String title, bool isFirst)
      : assert(title != null),
        super(title, title, isFirst);

  @override
  String get start => '''
    class _$title implements $ABSTRACT_CLASS_NAME {
  ''';

  @override
  String get interfaceStart => '''
    abstract class $ABSTRACT_CLASS_NAME {
  ''';

  @override
  String toString() {
    String result = namespaces;
    if (isFirst) {
      result += interfaceStart + interface + end;
    }
    return result + start + messages + end;
  }
}
