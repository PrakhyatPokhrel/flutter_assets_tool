import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

class PubspecHandler {
  final File pubspecFile;

  PubspecHandler(String projectPath)
      : pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));

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
