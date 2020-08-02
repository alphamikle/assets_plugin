import 'package:assets_codegen/src/constants/common_constants.dart';
import 'package:assets_codegen/src/templates/language_template.dart';

class IntlTemplate {
  final String _title;
  final Map<String, String> _abstractFields = {};

  IntlTemplate(this._title);

  String _mapTemplate = '';

  String _languageClasses = '';

  String get _templatesMapStart => '''
  final Map<String, $ABSTRACT_CLASS_NAME> _languageMap = {
  ''';

  String get _templatesMapEnd => '''
  };\n
  ''';

  String get _start => '''
  class _\$$_title extends LocalizationsDelegate<$ABSTRACT_CLASS_NAME> {
    @override
    bool isSupported(Locale locale) => _languageMap.keys.contains(locale.languageCode);
  
    @override
    Future<$ABSTRACT_CLASS_NAME> load(Locale locale) async {
      Intl.defaultLocale = locale.countryCode == null ? locale.languageCode : locale.toString();
      return _languageMap[locale.languageCode];
    }
    
    @override
    bool shouldReload(LocalizationsDelegate<$ABSTRACT_CLASS_NAME> old) => false;
  ''';

  String get _end => '''
  }\n
  ''';

  String get _messagesUtil => '''  
  class Messages {
    static $ABSTRACT_CLASS_NAME of(BuildContext context) => Localizations.of(context, $ABSTRACT_CLASS_NAME);
  }
  ''';

  String get template {
    return _languageClasses + _start + _templatesMapStart + _mapTemplate + _templatesMapEnd + _end + _messagesUtil;
  }

  void addLanguage(String code, LanguageTemplate languageTemplate) {
    _languageClasses += languageTemplate.toString();
    _mapTemplate += '''
    '$code': _${languageTemplate.title}(),
    ''';
  }
}
