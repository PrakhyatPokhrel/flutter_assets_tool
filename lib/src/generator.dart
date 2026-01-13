import 'dart:io';
import 'package:path/path.dart' as p;

class Generator {
  final String projectPath;
  final String outputPath;

  Generator(this.projectPath, {this.outputPath = 'lib/generated/assets.dart'});

  String _toCamelCase(String text) {
    // Remove extension and path separators
    final name = p.basenameWithoutExtension(text);
    final parts = name.split(RegExp(r'(_|-|\s)'));
    final result = StringBuffer(parts[0].toLowerCase());
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      result.write(
          parts[i][0].toUpperCase() + parts[i].substring(1).toLowerCase());
    }
    return result.toString();
  }

  Future<void> generate(List<String> assetPaths) async {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln('class Assets {');
    buffer.writeln('  Assets._();');
    buffer.writeln();

    for (final assetPath in assetPaths) {
      final variableName = _toCamelCase(assetPath);
      buffer.writeln("  static const String $variableName = '$assetPath';");
    }

    buffer.writeln('}');

    final outputFile = File(p.join(projectPath, outputPath));
    if (!outputFile.parent.existsSync()) {
      outputFile.parent.createSync(recursive: true);
    }
    await outputFile.writeAsString(buffer.toString());
  }
}
