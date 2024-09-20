import 'dart:io';
import 'package:dartvcs/dartvcs.dart';

void main(List<String> arguments) async {
  final vcs = DartVCS();
  
  print('Welcome to DartVCS!');
  print('Type "help" for a list of commands.');

  while (true) {
    stdout.write('dartvcs> ');
    final input = stdin.readLineSync()?.trim().toLowerCase();
    if (input == null || input.isEmpty) continue;

    final parts = input.split(' ');
    final command = parts[0];
    final args = parts.sublist(1);

    try {
      switch (command) {
        case 'init':
          await vcs.init();
          print('Initialized empty DartVCS repository.');
          break;
        case 'add':
          if (args.isEmpty) {
            print('Usage: add <filename>');
            continue;
          }
          await vcs.add(args[0]);
          print('Added ${args[0]} to staging area.');
          break;
        case 'commit':
          if (args.isEmpty) {
            print('Usage: commit <message>');
            continue;
          }
          final hash = await vcs.commit(args.join(' '));
          print('Committed changes with hash: $hash');
          break;
        case 'log':
          final logs = await vcs.log();
          if (logs.isEmpty) {
            print('No commits yet.');
          } else {
            logs.forEach(print);
          }
          break;
        case 'status':
          final status = await vcs.status();
          print(status);
          break;
        case 'diff':
          if (args.isEmpty) {
            print('Usage: diff <filename>');
            continue;
          }
          final diff = await vcs.diff(args[0]);
          print(diff);
          break;
        case 'help':
          printHelp();
          break;
        case 'exit':
          print('Thank you for using DartVCS!');
          return;
        default:
          print('Unknown command. Type "help" for a list of commands.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

void printHelp() {
  print('''
Available commands:
  init              Initialize a new DartVCS repository
  add <filename>    Add a file to the staging area
  commit <message>  Commit changes with a message
  log               Show commit history
  status            Show the current status of the repository
  diff <filename>   Show changes in a file
  help              Show this help message
  exit              Exit the program
''');
}