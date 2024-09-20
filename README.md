# DartVCS

DartVCS is a simple, Git-like version control system implemented in Dart. It provides basic version control functionality through a command-line interface.

## Features

- Initialize a new repository
- Add files to staging area
- Commit changes with messages
- View commit history
- Check repository status
- View file diffs

## Getting Started

### Prerequisites

- Dart SDK (version 2.12 or later)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/qharny/dartvcs.git
   ```

2. Navigate to the project directory:
   ```
   cd dartvcs
   ```

3. Install dependencies:
   ```
   dart pub get
   ```

## Usage

Run the application using:

```
dart run bin/dartvcs.dart
```

### Available Commands

- `init`: Initialize a new DartVCS repository
- `add <filename>`: Add a file to the staging area
- `commit <message>`: Commit changes with a message
- `log`: Show commit history
- `status`: Show the current status of the repository
- `diff <filename>`: Show changes in a file
- `help`: Show help message
- `exit`: Exit the program

## Example Usage

```
$ dart run bin/dartvcs.dart
Welcome to DartVCS!
Type "help" for a list of commands.
dartvcs> init
Initialized empty DartVCS repository.
dartvcs> add example.txt
Added example.txt to staging area.
dartvcs> commit "Initial commit"
Committed changes with hash: a1b2c3d4...
dartvcs> log
Commit: a1b2c3d4...
message Initial commit
dartvcs> exit
Thank you for using DartVCS!
```

## Running Tests

To run the test suite:

```
dart test
```

## Project Structure

- `bin/dartvcs.dart`: Main entry point of the application
- `lib/dartvcs.dart`: Core functionality of the version control system
- `test/dartvcs_test.dart`: Test suite

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Qharny/Contact_Form/edit/main/LICENSE) file for details.

## Acknowledgments

- Inspired by Git and other distributed version control systems
- Built with Dart