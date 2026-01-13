import 'package:watcher/watcher.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:async';

class AssetWatcher {
  final String projectPath;
  final Function() onAssetsChanged;
  final Function() onCodeChanged;

  AssetWatcher(this.projectPath,
      {required this.onAssetsChanged, required this.onCodeChanged});

  StreamSubscription? _assetSub;
  StreamSubscription? _codeSub;

  void start(List<String> assetFolders) {
    // Watch asset folders
    final watchedPaths = <String>{};
    for (final folder in assetFolders) {
      String watchPath;
      if (folder.endsWith('/')) {
        watchPath = p.join(projectPath, folder);
      } else {
        watchPath = p.dirname(p.join(projectPath, folder));
      }

      if (watchedPaths.contains(watchPath)) continue;
      watchedPaths.add(watchPath);

      if (Directory(watchPath).existsSync()) {
        final watcher = DirectoryWatcher(watchPath);
        _assetSub = watcher.events.listen((event) {
          onAssetsChanged();
        });
      }
    }

    // Watch code folder (lib)
    final libPath = p.join(projectPath, 'lib');
    if (Directory(libPath).existsSync()) {
      final watcher = DirectoryWatcher(libPath);
      _codeSub = watcher.events.listen((event) {
        if (event.path.endsWith('.dart')) {
          onCodeChanged();
        }
      });
    }
  }

  void stop() {
    _assetSub?.cancel();
    _codeSub?.cancel();
  }
}
