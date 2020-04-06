import 'package:assets_codegen/src/assets_generator.dart';
import 'package:assets_codegen/src/intl_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Assets code generator
Builder assetsCodeGen(BuilderOptions options) => SharedPartBuilder([AssetsGenerator(options)], 'assets_generator');
// Intl code generator
Builder intlCodeGen(BuilderOptions options) => SharedPartBuilder([IntlGenerator(options)], 'intl_generator');
