import 'package:watcher/watcher.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:async';

/// A watcher for tracking changes in assets and source code.
class AssetWatcher {
  /// The path to the project root.
  final String projectPath;

  /// Callback called when assets change.
  final Function() onAssetsChanged;

  /// Callback called when code changes.
  final Function() onCodeChanged;

  /// Creates a new [AssetWatcher] for the project at [projectPath].
  AssetWatcher(this.projectPath,
      {required this.onAssetsChanged, required this.onCodeChanged});

  StreamSubscription? _assetSub;
  StreamSubscription? _codeSub;

  /// Starts watching [assetFolders] and the `lib/` directory.
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

  /// Stops watching for changes.
  void stop() {
    _assetSub?.cancel();
    _codeSub?.cancel();
  }
}
