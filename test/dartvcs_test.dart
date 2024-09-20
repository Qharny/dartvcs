import 'dart:io';
import 'package:test/test.dart';
import 'package:dartvcs/dartvcs.dart';
import 'package:path/path.dart' as path;

void main() {
  late DartVCS vcs;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('dartvcs_test_');
    Directory.current = tempDir.path;
    vcs = DartVCS();
    await vcs.init();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('Init creates necessary directories and files', () async {
    expect(await Directory('.dartvcs').exists(), isTrue);
    expect(await Directory('.dartvcs/objects').exists(), isTrue);
    expect(await File('.dartvcs/index').exists(), isTrue);
    expect(await File('.dartvcs/HEAD').exists(), isTrue);
  });

  test('Add stages a file', () async {
    final testFile = File('test.txt');
    await testFile.writeAsString('Test content');
    await vcs.add('test.txt');

    final indexContent = await File('.dartvcs/index').readAsString();
    expect(indexContent, contains('test.txt'));
  });

  test('Commit creates a commit object', () async {
    final testFile = File('test.txt');
    await testFile.writeAsString('Test content');
    await vcs.add('test.txt');
    final commitHash = await vcs.commit('Initial commit');

    expect(await File('.dartvcs/objects/$commitHash').exists(), isTrue);
    expect(await File('.dartvcs/HEAD').readAsString(), equals(commitHash));
  });

  test('Log returns commit history', () async {
    final testFile = File('test.txt');
    await testFile.writeAsString('Test content');
    await vcs.add('test.txt');
    await vcs.commit('Initial commit');

    final logs = await vcs.log();
    expect(logs.length, equals(1));
    expect(logs[0], contains('Initial commit'));
  });

  test('Status shows staged changes', () async {
    final testFile = File('test.txt');
    await testFile.writeAsString('Test content');
    await vcs.add('test.txt');

    final status = await vcs.status();
    expect(status, contains('test.txt'));
  });

  test('Diff shows changes in a file', () async {
    final testFile = File('test.txt');
    await testFile.writeAsString('Initial content');
    await vcs.add('test.txt');
    await vcs.commit('Initial commit');

    await testFile.writeAsString('Modified content');
    final diff = await vcs.diff('test.txt');
    expect(diff, contains('- Initial content'));
    expect(diff, contains('+ Modified content'));
  });
}