# assets_plugin

#### Code generator for assets plugin

This plugin consist of three packages:
- [assets_annotations](https://github.com/alphamikle/assets_plugin/tree/master/assets_annotations) - [pub.dev](https://pub.dev/packages/assets_annotations)
- [assets_codegen](https://github.com/alphamikle/assets_plugin/tree/master/assets_codegen) - [pub.dev](https://pub.dev/packages/assets_codegen)
- [assets_example](https://github.com/alphamikle/assets_plugin/tree/master/assets_example)

## Getting Started

This package should use with the asset_annotation package.
The main idea of this is a generating dart class with fields, which can help you access your assets in code and give you autocomplete and static preload of text assets in one place.
For an example of usage go-to example project.
You can configure the generator in a build.ya?ml file of your project. At now the only thing is an extension of files, which can be preloaded. By default, it is a .txt and .json files, but you can pass your additional types in this
manner:
```yaml
targets:
  $default:
    builders:
      assets_codegen:
        options:
          preload:
            - your_file_type
            - other_your_file_type
```
To use this package - install it and create file such as
```dart
import 'package:assets_annotations/assets_annotations.dart';
import 'package:flutter/services.dart'; // <== IT IMPORT IS REQUIRED FOR WORKING AUTO-PRELOAD FOR DEFINED FILE EXTENSIONS (json, txt, etc...)

part 'asset_helper.g.dart';

@AstHelp()
class AssetHelper with _$TextHelper {}
```
Plugin will search assets section in your pubspec.ya?ml file and watch directories, which is described there and deeper (recursive), after you run
```bash
flutter pub run build_runner build|watch [--delete-conflicting-outputs]
```
plugin will generate mixin near your annotated file-class.