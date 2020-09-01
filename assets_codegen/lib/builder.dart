import 'package:assets_codegen/src/assets_generator.dart';
import 'package:assets_codegen/src/intl_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Map<String, dynamic> params = {};

/// Assets code generator
Builder assetsCodeGen(BuilderOptions options) {
  params.clear();
  params = options.config;
  return SharedPartBuilder([AssetsGenerator(options)], 'assets_generator');
}

// Intl code generator
Builder intlCodeGen(BuilderOptions options) {
  if (params['once'] == true) {
    options.config['once'] = true;
  }
  return SharedPartBuilder([IntlGenerator(options)], 'intl_generator');
}
