# assets_plugin

#### Code generator for assets plugin

This plugin consist of three packages:
- [assets_annotations](https://github.com/alphamikle/assets_plugin/tree/master/assets_annotations) - [pub.dev](https://pub.dev/packages/assets_annotations)
- [assets_codegen](https://github.com/alphamikle/assets_plugin/tree/master/assets_codegen) - [pub.dev](https://pub.dev/packages/assets_codegen)
- [assets_example](https://github.com/alphamikle/assets_plugin/tree/master/assets_example)

## Getting Started

### @AstHelp part:
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
class AssetHelper with _$AssetHelper {}
```
Plugin will search assets section in your pubspec.ya?ml file and watch directories, which is described there and deeper (recursive), after you run
```bash
flutter pub run build_runner build|watch [--delete-conflicting-outputs]
```
plugin will generate mixin near your annotated file-class.

### @IntlHelp part:

From version 1.1.0 this plugin can help you to generate LocalizationDelegates easy as possible from yaml files with your messages.
That yaml files must be placed in language code folders, for example:
.../ru/intl.yaml
.../en/intl.yaml
or contain language code delimited by dot with prefix:
.../ru.intl.yaml
.../en.intl.yaml

For example this file will produce Delegate:
```yaml
ok: OK

save:
  value: Save
  desc: Saving something

book:
  zero: books
  one: book
  two: books
  other: books
  desc: Uses for description of books count

namespacedZone:
  title: Title of Namespaced zone
  description: Description of Namespaced zone
  checkout:
    title: Checkoout for additional page
  innerNamespacedZone:
    title: Deeper title of Inner namespaced zone
    description: Deeper description of Inner namespaced zone
    book:
      zero: books
      one: book
      two: books
      few: books
      many: books
      other: books
      desc: Uses for description of books count

cart:
  title: Cart
  description: Please, fill the cart to do checkout
  checkout:
    title: Checkout
    description: You should checkout
```

After you create your messages yaml files you should place its at asset folder (or other folder, which is marked as "asset" in your pubspec.yaml. Each language yaml must contain a "intl" substring or other,
if you want by pass prefix param to @IntlHelp annotation:
```dart
@IntlHelp(prefix: 'your_yaml_files_prefix')
class LocalizationDelegate extends _$LocalizationDelegate {}
```

Then all you need to get your LocalizationDelegate is:
```dart
import 'package:assets_annotations/assets_annotations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'localization_delegate.g.dart';

@IntlHelp()
class LocalizationDelegate extends _$LocalizationDelegate {}
```

then run
```bash
flutter pub run build_runner build|watch [--delete-conflicting-outputs]
```

and use generated delegate in your app:
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        LocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('ru'),
      ],
      title: 'Assets demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
```
...
```dart
@override
  Widget build(BuildContext context) {
    final LocalizationMessages _loc = Messages.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${Messages.of(context).book(1)} app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildText('You have $_counter ${_loc.book(_counter)}'),
            _buildText('Namespaced title: ${_loc.namespacedZone.title}'),
            _buildText('Checkout from one namespace: ${_loc.namespacedZone.checkout.title}'),
            _buildText('Checkout from other namespace: ${_loc.cart.checkout.title}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
```
You can ask what is a Messages?, well, it's is a generated helper for extract you messages from context, which can be imported from generated file:
```dart
class Messages {
  static LocalizationMessages of(BuildContext context) =>
      Localizations.of(context, LocalizationMessages);
}
```
![EN Translation](https://github.com/alphamikle/assets_plugin/blob/master/assets_example/assets/img/en.png)
![RU Translation](https://github.com/alphamikle/assets_plugin/blob/master/assets_example/assets/img/ru.png)