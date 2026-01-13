import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

/// A handler for interacting with the `pubspec.yaml` file.
class PubspecHandler {
  /// The `pubspec.yaml` file.
  final File pubspecFile;

  /// Creates a new [PubspecHandler] for the project at [projectPath].
  PubspecHandler(String projectPath)
      : pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));

  /// Returns a list of asset paths defined in the `pubspec.yaml` file.
  ///
  /// Throws an [Exception] if `pubspec.yaml` is not found.
  Future<List<String>> getAssetPaths() async {
    if (!await pubspecFile.exists()) {
      throw Exception('pubspec.yaml not found at ${pubspecFile.path}');
    }

    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);

    if (yaml == null ||
        yaml['flutter'] == null ||
        yaml['flutter']['assets'] == null) {
      return [];
    }

    final yamlAssets = yaml['flutter']['assets'] as YamlList;
    return yamlAssets.map((e) => e.toString()).toList();
  }
}
