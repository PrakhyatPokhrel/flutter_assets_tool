import 'package:flutter_assets_tool/flutter_assets_tool.dart';
import 'dart:io';

void main() async {
  // Use the current directory as the project root (assuming it's run from the project root or example folder)
  // For this example, we'll just demonstrate the components.
  final projectPath = Directory.current.path;
  print('Project path: $projectPath');

  final pubspecHandler = PubspecHandler(projectPath);

  try {
    final assetPaths = await pubspecHandler.getAssetPaths();
    print('Assets defined in pubspec: $assetPaths');

    final scanner = Scanner(projectPath);
    final allAssets = scanner.scanAll(assetPaths);
    print('Found ${allAssets.length} asset files');

    final parser = Parser(projectPath);
    final referencedAssets = await parser.findReferences(allAssets);

    final usedAssets = <Asset>[];
    final unusedAssets = <Asset>[];

    for (final path in allAssets) {
      final isUsed = referencedAssets.contains(path);
      final asset = Asset(path: path, isUsed: isUsed);
      if (isUsed) {
        usedAssets.add(asset);
      } else {
        unusedAssets.add(asset);
      }
    }

    final result = AssetScanResult(
      usedAssets: usedAssets,
      unusedAssets: unusedAssets,
    );

    print('Summary:');
    print('  - Used assets: ${result.usedAssets.length}');
    print('  - Unused assets: ${result.unusedAssets.length}');

    if (result.unusedAssets.isNotEmpty) {
      print('\nUnused assets:');
      for (final asset in result.unusedAssets) {
        print('  - ${asset.path}');
      }
    }
  } catch (e) {
    print('Error: $e');
    print(
        '\nTo run this example successfully, make sure you are in a Flutter project directory with assets defined in pubspec.yaml.');
  }
}
