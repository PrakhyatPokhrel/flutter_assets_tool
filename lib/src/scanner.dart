import 'dart:io';
import 'package:path/path.dart' as p;

/// A scanner for finding asset files in the project.
class Scanner {
  /// The path to the project root.
  final String projectPath;

  /// Creates a new [Scanner] for the project at [projectPath].
  Scanner(this.projectPath);

  /// Scans the folder at [folderPath] (relative to [projectPath]) for files.
  List<String> scanFolder(String folderPath) {
    final dir = Directory(p.join(projectPath, folderPath));
    if (!dir.existsSync()) return [];

    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => p.relative(file.path, from: projectPath))
        .toList();
  }

  /// Scans all paths in [assetPaths] for files.
  ///
  /// For folders (ending with `/`), it scans the folder recursively.
  /// For single files, it adds them if they exist.
  List<String> scanAll(List<String> assetPaths) {
    final allFiles = <String>{};
    for (final path in assetPaths) {
      if (path.endsWith('/')) {
        allFiles.addAll(scanFolder(path));
      } else {
        // It's a single file
        final file = File(p.join(projectPath, path));
        if (file.existsSync()) {
          allFiles.add(p.relative(file.path, from: projectPath));
        }
      }
    }
    return allFiles.toList()..sort();
  }
}
