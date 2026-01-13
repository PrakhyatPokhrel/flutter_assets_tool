import 'dart:io';
import 'package:path/path.dart' as p;

class Scanner {
  final String projectPath;

  Scanner(this.projectPath);

  List<String> scanFolder(String folderPath) {
    final dir = Directory(p.join(projectPath, folderPath));
    if (!dir.existsSync()) return [];

    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => p.relative(file.path, from: projectPath))
        .toList();
  }

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
