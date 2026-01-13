import 'dart:io';
import 'package:path/path.dart' as p;

/// A cleaner for removing unused assets from the project.
class Cleaner {
  /// The path to the project root.
  final String projectPath;

  /// Creates a new [Cleaner] for the project at [projectPath].
  Cleaner(this.projectPath);

  /// Deletes or moves [unusedAssets] to a [backupFolder].
  ///
  /// If [backupFolder] is provided, the assets are moved there instead of being deleted.
  Future<void> clean(List<String> unusedAssets, {String? backupFolder}) async {
    for (final assetPath in unusedAssets) {
      final file = File(p.join(projectPath, assetPath));
      if (!file.existsSync()) continue;

      if (backupFolder != null) {
        final backupDir = Directory(p.join(projectPath, backupFolder));
        if (!backupDir.existsSync()) {
          backupDir.createSync(recursive: true);
        }
        final backupPath = p.join(backupDir.path, assetPath);
        final backupFile = File(backupPath);
        if (!backupFile.parent.existsSync()) {
          backupFile.parent.createSync(recursive: true);
        }
        await file.rename(backupPath);
      } else {
        await file.delete();
      }
    }
  }
}
