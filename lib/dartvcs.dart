import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class DartVCS {
  late Directory _rootDir;
  late Directory _objectsDir;
  late File _indexFile;
  late File _headFile;

  Future<void> init() async {
    _rootDir = Directory.current;
    _objectsDir = Directory(path.join(_rootDir.path, '.dartvcs', 'objects'));
    _indexFile = File(path.join(_rootDir.path, '.dartvcs', 'index'));
    _headFile = File(path.join(_rootDir.path, '.dartvcs', 'HEAD'));

    await _objectsDir.create(recursive: true);
    await _indexFile.create(recursive: true);
    await _headFile.writeAsString('');
  }

  Future<void> add(String filename) async {
    final file = File(path.join(_rootDir.path, filename));
    if (!await file.exists()) {
      throw Exception('File does not exist');
    }

    final content = await file.readAsString();
    final hash = _generateHash(content);
    
    final objectFile = File(path.join(_objectsDir.path, hash));
    await objectFile.writeAsString(content);

    final index = await _readIndex();
    index[filename] = hash;
    await _writeIndex(index);
  }

  Future<String> commit(String message) async {
    final index = await _readIndex();
    if (index.isEmpty) {
      throw Exception('Nothing to commit');
    }

    final commitContent = 'tree ${_generateHash(json.encode(index))}\n'
        'parent ${await _getHead()}\n'
        'message $message\n';
    
    final commitHash = _generateHash(commitContent);
    final commitFile = File(path.join(_objectsDir.path, commitHash));
    await commitFile.writeAsString(commitContent);

    await _headFile.writeAsString(commitHash);
    await _indexFile.writeAsString('');  // Clear index after commit

    return commitHash;
  }

  Future<List<String>> log() async {
    final logs = <String>[];
    var currentHash = await _getHead();

    while (currentHash.isNotEmpty) {
      final commitFile = File(path.join(_objectsDir.path, currentHash));
      final commitContent = await commitFile.readAsString();
      logs.add('Commit: $currentHash\n$commitContent');

      final parentMatch = RegExp(r'parent (.+)').firstMatch(commitContent);
      currentHash = parentMatch?.group(1) ?? '';
    }

    return logs;
  }

  Future<String> status() async {
    final index = await _readIndex();
    if (index.isEmpty) {
      return 'No changes staged for commit.';
    }

    return 'Changes staged for commit:\n' +
        index.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
  }

  Future<String> diff(String filename) async {
    final file = File(path.join(_rootDir.path, filename));
    if (!await file.exists()) {
      throw Exception('File does not exist');
    }

    final currentContent = await file.readAsString();
    final index = await _readIndex();
    final stagedHash = index[filename];

    if (stagedHash == null) {
      return 'File is not staged';
    }

    final stagedFile = File(path.join(_objectsDir.path, stagedHash));
    final stagedContent = await stagedFile.readAsString();

    return _generateDiff(stagedContent, currentContent);
  }

  String _generateHash(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, String>> _readIndex() async {
    if (!await _indexFile.exists()) {
      return {};
    }
    final content = await _indexFile.readAsString();
    return content.isEmpty ? {} : json.decode(content);
  }

  Future<void> _writeIndex(Map<String, String> index) async {
    await _indexFile.writeAsString(json.encode(index));
  }

  Future<String> _getHead() async {
    if (!await _headFile.exists()) {
      return '';
    }
    return await _headFile.readAsString();
  }

  String _generateDiff(String oldContent, String newContent) {
    final oldLines = oldContent.split('\n');
    final newLines = newContent.split('\n');
    final diff = [];

    for (var i = 0; i < oldLines.length || i < newLines.length; i++) {
      if (i >= oldLines.length) {
        diff.add('+ ${newLines[i]}');
      } else if (i >= newLines.length) {
        diff.add('- ${oldLines[i]}');
      } else if (oldLines[i] != newLines[i]) {
        diff.add('- ${oldLines[i]}');
        diff.add('+ ${newLines[i]}');
      }
    }

    return diff.join('\n');
  }
}