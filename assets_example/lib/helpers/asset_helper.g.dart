// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_helper.dart';

// **************************************************************************
// Generator of asset_helper
// **************************************************************************

enum Asset {
  second,
  first,
  secondCopy,
}

final Map<Asset, String> _assetEnumMap = {
  Asset.second: 'assets/second.json',
  Asset.first: 'assets/text/first.txt',
  Asset.secondCopy: 'assets/text/second.txt',
};

mixin _$AssetHelper {
  final second = 'assets/second.json';
  final rigDemo = 'assets/rive/Rig Demo.flr2d';
  final oneCow = 'assets/img/one cow.png';
  final twoCows = 'assets/img/two cows.png';
  final zeroCows = 'assets/img/zero cows.png';
  final third = 'assets/img/third.png';
  final first = 'assets/text/first.txt';
  final secondCopy = 'assets/text/second.txt';
  final intl = 'assets/localization/ru/intl.yaml';
  final intlCopy = 'assets/localization/en/intl.yaml';
  final Map<Asset, String> _preloadedAssets = Map();
  bool isPreloaded = false;
  Future<bool> preloadAssets() async {
    final List<Future> loaders = [];
    loadAsset(Asset asset) async {
      final String assetContent =
          await rootBundle.loadString(_assetEnumMap[asset], cache: false);
      _preloadedAssets[asset] = assetContent;
    }

    for (Asset assetEnumField in Asset.values) {
      loaders.add(loadAsset(assetEnumField));
    }
    await Future.wait(loaders);
    isPreloaded = true;
    return isPreloaded;
  }

  String getAssetData(Asset assetEnum) {
    if (!isPreloaded) {
      throw Exception(
          'You should run method "preloadAssets" before accessing data with "getAssetData" method');
    }
    return _preloadedAssets[assetEnum];
  }
}
