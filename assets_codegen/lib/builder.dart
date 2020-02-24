import 'package:assets_codegen/src/assets_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder assetsCodeGen(BuilderOptions options) =>
    SharedPartBuilder([AssetsGenerator(options)], 'assets_generator');
