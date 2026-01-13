import 'package:flutter_assets_tool/flutter_assets_tool.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  group('Scanner Tests', () {
    test('should identify files in folder', () {
      final tempDir = Directory.systemTemp.createTempSync('fassets_test_');
      try {
        final assetsDir = Directory(p.join(tempDir.path, 'assets'))
          ..createSync();
        File(p.join(assetsDir.path, 'logo.png')).createSync();
        File(p.join(assetsDir.path, 'bg.png')).createSync();

        final scanner = Scanner(tempDir.path);
        final results = scanner.scanFolder('assets/');

        expect(results.length, 2);
        expect(results, contains('assets/logo.png'));
        expect(results, contains('assets/bg.png'));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('Parser Tests', () {
    test('should find references in mock file', () async {
      final tempDir =
          Directory.systemTemp.createTempSync('fassets_parser_test_');
      try {
        final libDir = Directory(p.join(tempDir.path, 'lib'))..createSync();
        final mainFile = File(p.join(libDir.path, 'main.dart'));
        await mainFile.writeAsString(
            "Image.asset('assets/logo.png'); // assets/commented.png");

        final parser = Parser(tempDir.path);
        final results = await parser
            .findReferences(['assets/logo.png', 'assets/commented.png']);

        expect(results, contains('assets/logo.png'));
        expect(results, isNot(contains('assets/commented.png')));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
