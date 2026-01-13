class Asset {
  final String path;
  final bool isUsed;

  Asset({required this.path, this.isUsed = false});

  @override
  String toString() => 'Asset(path: $path, isUsed: $isUsed)';
}

class AssetScanResult {
  final List<Asset> usedAssets;
  final List<Asset> unusedAssets;

  AssetScanResult({required this.usedAssets, required this.unusedAssets});

  List<Asset> get allAssets => [...usedAssets, ...unusedAssets];
}
