// IntlHelp is internationalization helper for generate dart messages mixins
class IntlHelp {
  const IntlHelp({this.prefix = 'intl'}) : assert(prefix != null && prefix != '');

  final String prefix;
}
