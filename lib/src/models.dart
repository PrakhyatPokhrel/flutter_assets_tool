/// Represents a Flutter asset.
class Asset {
  /// The relative path of the asset from the project root.
  final String path;

  /// Whether the asset is used in the project's source code.
  final bool isUsed;

  /// Creates a new [Asset] instance.
  Asset({required this.path, this.isUsed = false});

  @override
  String toString() => 'Asset(path: $path, isUsed: $isUsed)';
}

/// Represents the result of an asset scan.
class AssetScanResult {
  /// The list of assets that are used in the project.
  final List<Asset> usedAssets;

  /// The list of assets that are not used in the project.
  final List<Asset> unusedAssets;

  /// Creates a new [AssetScanResult] instance.
  AssetScanResult({required this.usedAssets, required this.unusedAssets});

  /// Returns a list of all assets (both used and unused).
  List<Asset> get allAssets => [...usedAssets, ...unusedAssets];
}
