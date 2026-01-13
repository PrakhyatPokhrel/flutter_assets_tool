import 'dart:io';
import 'package:path/path.dart' as p;

/// A parser for finding asset references in Dart source code.
class Parser {
  /// The path to the project root.
  final String projectPath;

  /// Creates a new [Parser] for the project at [projectPath].
  Parser(this.projectPath);

  /// Finds references to the assets in [allAssets] within the `lib/` directory.
  ///
  /// Returns a set of asset paths that are referenced in the code.
  Future<Set<String>> findReferences(List<String> allAssets) async {
    final referencedAssets = <String>{};
    final libDir = Directory(p.join(projectPath, 'lib'));
    if (!libDir.existsSync()) return referencedAssets;

    final entities = libDir.listSync(recursive: true);

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final File file = entity;
        if (p.basename(file.path) == 'assets.dart') continue;

        var content = await file.readAsString();
        content = _stripComments(content);

        for (final asset in allAssets) {
          if (referencedAssets.contains(asset)) continue;

          // Strategy 1: Exact full path match
          if (content.contains(asset)) {
            referencedAssets.add(asset);
            continue;
          }

          // Strategy 2: Filename match (to handle dynamic concatenation like link + 'filename.svg')
          // We check for 'filename.svg' or "filename.svg" to reduce false positives
          final filename = p.basename(asset);
          if (content.contains("'$filename'") ||
              content.contains('"$filename"')) {
            referencedAssets.add(asset);
          }
        }
      }
    }

    return referencedAssets;
  }

  String _stripComments(String content) {
    // Remove single line comments
    content = content.replaceAll(RegExp(r'//.*'), '');
    // Remove multi-line comments
    content = content.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
    return content;
  }
}
