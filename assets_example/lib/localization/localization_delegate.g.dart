// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_delegate.dart';

// **************************************************************************
// Generator of localization_delegate
// **************************************************************************

abstract class LocalizationMessages {
  final String ok = '';

  /// Описание поля "Жена"
  String wife(int howMany) => '';

  String wife_collision(int howMany) => '';

  /// Описание поля "Муж"
  String husband(int howMany) => '';

  /// Отправить что-то куда-то
  final String send = '';

  /// Сохранение чего-либо где-либо
  final String save = '';

  /// Используется для описания количества детей
  String child(int howMany) => '';

  /// Используется для описания количества коров
  String cow(int howMany) => '';

  final String new_message = '';
}

class _Ru extends LocalizationMessages {
  @override
  final String ok = Intl.message('OK', name: 'ok');

  @override
  String wife(int howMany) => Intl.plural(howMany,
      name: 'wife',
      zero: '$howMany Жён',
      one: '$howMany Жена',
      other: '$howMany Жены',
      desc: 'Описание поля "Жена"');

  @override
  String wife_collision(int howMany) => Intl.plural(howMany,
      name: 'wife_collision',
      zero: '$howMany Жён',
      one: '$howMany Жена',
      other: '$howMany Жёны',
      two: '$howMany Жены');

  @override
  String husband(int howMany) => Intl.plural(howMany,
      name: 'husband',
      zero: '$howMany мужей',
      one: '$howMany муж',
      other: '$howMany мужа',
      two: '$howMany мужа',
      desc: 'Описание поля "Муж"');

  @override
  final String send =
      Intl.message('Отправить', name: 'send', desc: 'Отправить что-то куда-то');

  @override
  final String save = Intl.message('Сохранить',
      name: 'save', desc: 'Сохранение чего-либо где-либо');

  @override
  String child(int howMany) => Intl.plural(howMany,
      name: 'child',
      zero: '$howMany Детей',
      one: '$howMany Ребенок',
      other: '$howMany Дети',
      two: '$howMany Ребенка',
      desc: 'Используется для описания количества детей');

  @override
  String cow(int howMany) => Intl.plural(howMany,
      name: 'cow',
      zero: '$howMany коров',
      one: '$howMany корова',
      other: '$howMany коровы',
      desc: 'Используется для описания количества коров');

  @override
  final String new_message =
      Intl.message('Новое сообщение', name: 'new_message');
}

class _En extends LocalizationMessages {
  @override
  final String ok = Intl.message('OK', name: 'ok');

  @override
  String wife(int howMany) => Intl.plural(howMany,
      name: 'wife',
      zero: '$howMany wives',
      one: '$howMany wife',
      other: '$howMany wives',
      desc: 'Описание поля "Жена"');

  @override
  String wife_collision(int howMany) => Intl.plural(howMany,
      name: 'wife_collision',
      zero: '$howMany wives',
      one: '$howMany wife',
      other: '$howMany wives',
      two: '$howMany wives');

  @override
  String husband(int howMany) => Intl.plural(howMany,
      name: 'husband',
      zero: '$howMany husbands',
      one: '$howMany husband',
      other: '$howMany husbands',
      two: '$howMany husbands',
      desc: 'Описание поля "Муж"');

  @override
  final String send =
      Intl.message('Send', name: 'send', desc: 'Отправить что-то куда-то');

  @override
  final String save =
      Intl.message('Save', name: 'save', desc: 'Сохранение чего-либо где-либо');

  @override
  String child(int howMany) => Intl.plural(howMany,
      name: 'child',
      zero: '$howMany children',
      one: '$howMany child',
      other: '$howMany children',
      two: '$howMany children',
      desc: 'Используется для описания количества детей');

  @override
  String cow(int howMany) => Intl.plural(howMany,
      name: 'cow',
      zero: '$howMany cows',
      one: '$howMany cow',
      other: '$howMany cows',
      desc: 'Используется для описания количества коров');

  @override
  final String new_message = Intl.message('New message', name: 'new_message');
}

class _$LocalizationDelegate
    extends LocalizationsDelegate<LocalizationMessages> {
  @override
  bool isSupported(Locale locale) =>
      _languageMap.keys.contains(locale.languageCode);

  @override
  Future<LocalizationMessages> load(Locale locale) async {
    Intl.defaultLocale =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    return _languageMap[locale.languageCode];
  }

  @override
  bool shouldReload(LocalizationsDelegate<LocalizationMessages> old) => false;
  final Map<String, LocalizationMessages> _languageMap = {
    'ru': _Ru(),
    'en': _En(),
  };
}

class Messages {
  static LocalizationMessages of(BuildContext context) =>
      Localizations.of(context, LocalizationMessages);
}
