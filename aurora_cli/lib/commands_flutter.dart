import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:aurora_cli/cli_constants.dart';
import 'package:aurora_cli/cli_di.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;
import 'package:async/async.dart' show StreamGroup;

enum CommandsFlutterArg {
  versions_installed,
  versions_available,
  install,
  remove,
  embedder_version,
  embedder_install
}

class CommandsFlutter extends Command<int> {
  CommandsFlutter() {
    argParser
      ..addFlag(
        'versions-installed',
        negatable: false,
        help: 'Get list installed versions Flutter SDK.',
      )
      ..addFlag(
        'versions-available',
        negatable: false,
        help: 'Get list available versions Flutter SDK.',
      )
      ..addOption(
        'install',
        help: 'Install version Flutter SDK.',
        valueHelp: 'flutter-version',
        defaultsTo: null,
      )
      ..addOption(
        'remove',
        help: 'Remove Flutter SDK.',
        valueHelp: 'flutter-version',
        defaultsTo: null,
      )
      ..addFlag(
        'embedder-version',
        negatable: false,
        help: 'Get version installed Flutter embedder.',
      )
      ..addOption(
        'embedder-install',
        help: 'Install embedder from Flutter SDK.',
        valueHelp: 'flutter-version',
        defaultsTo: null,
      );
  }

  @override
  String get description => 'Flutter helper for Aurora OS.';

  @override
  String get name => 'flutter';

  Logger get _logger => getIt<Logger>();

  CommandsFlutterArg? _getArg(ArgResults? args) {
    final list = [];

    if (argResults?['versions-installed'] == true) {
      list.add(CommandsFlutterArg.versions_installed);
    }

    if (argResults?['versions-available'] == true) {
      list.add(CommandsFlutterArg.versions_available);
    }

    if (argResults?['install'] != null &&
        argResults!['install'].toString().trim().isNotEmpty) {
      list.add(CommandsFlutterArg.install);
    }

    if (argResults?['remove'] != null &&
        argResults!['remove'].toString().trim().isNotEmpty) {
      list.add(CommandsFlutterArg.remove);
    }

    if (argResults?['embedder-version'] == true) {
      list.add(CommandsFlutterArg.embedder_version);
    }

    if (argResults?['embedder-install'] != null &&
        argResults!['embedder-install'].toString().trim().isNotEmpty) {
      list.add(CommandsFlutterArg.embedder_install);
    }

    if (list.length > 1) {
      _logger.info('Only one flag at a time!');
      list.clear();
    }
    if (list.isEmpty) {
      printUsage();
    }
    return list.firstOrNull;
  }

  @override
  Future<int> run() async {
    switch (_getArg(argResults)) {
      case CommandsFlutterArg.versions_installed:
        await _versions_installed();
        break;
      case CommandsFlutterArg.versions_available:
        await _versions_available();
        break;
      case CommandsFlutterArg.install:
        await _install();
        break;
      case CommandsFlutterArg.remove:
        await _remove();
        break;
      case CommandsFlutterArg.embedder_version:
        await _embedder_version();
        break;
      case CommandsFlutterArg.embedder_install:
        await _embedder_install();
        break;

      default:
        return ExitCode.usage.code;
    }
    return ExitCode.success.code;
  }

  Future<void> _versions_installed() async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'flutter_versions_installed.sh',
      ),
      [],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _versions_available() async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'flutter_versions_available.sh',
      ),
      [],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _install() async {
    _logger
      ..info('The installation has started, please wait...')
      ..info('');
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'flutter_install.sh',
      ),
      [
        '-v',
        argResults!['install'].toString(),
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _remove() async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'flutter_remove.sh',
      ),
      [
        '-v',
        argResults!['remove'].toString(),
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _embedder_version() async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'flutter_embedder_version.sh',
      ),
      [],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }

  Future<void> _embedder_install() async {
    final process = await Process.start(
      p.join(
        pathSnap,
        'scripts',
        'flutter_embedder_install.sh',
      ),
      [
        '-v',
        argResults!['embedder-install'].toString(),
      ],
    );
    await stdout.addStream(StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]));
  }
}
