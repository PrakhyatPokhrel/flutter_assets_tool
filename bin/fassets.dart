import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_assets_tool/src/pubspec_handler.dart';
import 'package:flutter_assets_tool/src/scanner.dart';
import 'package:flutter_assets_tool/src/parser.dart';
import 'package:flutter_assets_tool/src/generator.dart';
import 'package:flutter_assets_tool/src/cleaner.dart';
import 'package:flutter_assets_tool/src/watcher.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser();

  final cleanParser = parser.addCommand('clean');
  cleanParser.addOption('backup',
      abbr: 'b', help: 'Backup directory for unused assets');

  parser.addCommand('scan');
  parser.addCommand('gen');
  parser.addCommand('watch');

  ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    print('Error: $e');
    printUsage(parser);
    return;
  }

  final command = results.command?.name;
  if (command == null) {
    printUsage(parser);
    return;
  }

  final projectPath = Directory.current.path;
  final pubspecHandler = PubspecHandler(projectPath);
  final scanner = Scanner(projectPath);
  final codeParser = Parser(projectPath);
  final generator = Generator(projectPath);
  final cleaner = Cleaner(projectPath);

  final assetPathsInPubspec = await pubspecHandler.getAssetPaths();
  if (assetPathsInPubspec.isEmpty && command != 'watch') {
    print('No assets found in pubspec.yaml');
    return;
  }

  final allAssets = scanner.scanAll(assetPathsInPubspec);

  switch (command) {
    case 'scan':
      await handleScan(codeParser, allAssets);
      break;
    case 'gen':
      await handleGen(generator, allAssets);
      break;
    case 'clean':
      final backup = results.command?['backup'] as String?;
      await handleClean(codeParser, cleaner, allAssets, backup);
      break;
    case 'watch':
      await handleWatch(
          pubspecHandler, scanner, codeParser, generator, projectPath);
      break;
    default:
      printUsage(parser);
  }
}

void printUsage(ArgParser parser) {
  print('Flutter Assets Tool (fassets)');
  print('\nCommands:');
  for (final command in parser.commands.keys) {
    print('  $command');
  }
}

Future<void> handleScan(Parser parser, List<String> allAssets) async {
  print('Scanning for asset references in code...');
  final usedAssets = await parser.findReferences(allAssets);
  final unusedAssets = allAssets.where((a) => !usedAssets.contains(a)).toList();

  print('\nUsed Assets (${usedAssets.length}):');
  for (final asset in usedAssets) {
    print('  [USED] $asset');
  }

  print('\nUnused Assets (${unusedAssets.length}):');
  for (final asset in unusedAssets) {
    print('  [UNUSED] $asset');
  }
}

Future<void> handleGen(Generator generator, List<String> allAssets) async {
  print('Generating typed asset references...');
  await generator.generate(allAssets);
  print('Generated: lib/generated/assets.dart');
}

Future<void> handleClean(Parser parser, Cleaner cleaner, List<String> allAssets,
    String? backup) async {
  final usedAssets = await parser.findReferences(allAssets);
  final unusedAssets = allAssets.where((a) => !usedAssets.contains(a)).toList();

  if (unusedAssets.isEmpty) {
    print('No unused assets found.');
    return;
  }

  print('Cleaning ${unusedAssets.length} unused assets...');
  await cleaner.clean(unusedAssets, backupFolder: backup);
  print(
      'Cleaning completed${backup != null ? ' (backed up to $backup)' : ''}.');
}

Future<void> handleWatch(PubspecHandler pubspecHandler, Scanner scanner,
    Parser parser, Generator generator, String projectPath) async {
  print('Watching for changes in assets and code...');

  final assetPaths = await pubspecHandler.getAssetPaths();
  final watcher = AssetWatcher(
    projectPath,
    onAssetsChanged: () async {
      print('Assets changed, updating references...');
      final allAssets = scanner.scanAll(await pubspecHandler.getAssetPaths());
      await generator.generate(allAssets);
    },
    onCodeChanged: () async {
      print('Code changed, re-scanning...');
      // In watch mode, we might just want to update references if new files are added
    },
  );

  watcher.start(assetPaths);

  // Keep the process alive
  await Completer().future;
}
