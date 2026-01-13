import 'dart:io';
import 'package:path/path.dart' as p;

class Cleaner {
  final String projectPath;

  Cleaner(this.projectPath);

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
